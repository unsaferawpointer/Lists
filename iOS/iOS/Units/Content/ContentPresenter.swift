//
//  ContentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentPresenterProtocol: AnyObject {
	func present(items: [Item])
	func present(content: Content)
}

final class ContentPresenter {

	var interactor: ContentInteractorProtocol

	weak var view: ContentView?

	var coordinator: ContentCoordinatable?

	// MARK: - Cache

	private var cache: Cache = .init()

	// MARK: - Initialization

	init(interactor: ContentInteractorProtocol) {
		self.interactor = interactor
	}
}

// MARK: - ContentViewDelegate
extension ContentPresenter: ContentViewDelegate {

	func viewDidLoad() {
		Task { @MainActor in
			try? await interactor.fetchItems()
		}
	}

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) {
		Task { @MainActor [weak self] in
			try? await self?.interactor.moveItem(with: id, to: destination)
		}
	}
}

// MARK: - ContextMenuDelegate
extension ContentPresenter: ContextMenuDelegate {

	func contextMenuSelected(menuItem: String, with selection: [UUID], state: UIMenuElement.State) {
		switch menuItem {
		case "edit":
			guard let first = selection.first else {
				return
			}
			Task { @MainActor [weak self] in
				guard let item = try? await self?.interactor.item(for: first) else {
					return
				}
				let model = ItemEditorModel(title: item.title)
				self?.editItem(with: first, model: model)
			}
		case "delete":
			Task { @MainActor in
				try? await interactor.deleteItems(with: selection)
			}
		case "strikethrough":
			Task { @MainActor in
				try? await interactor.strikeThroughItems(with: selection, flag: state == .on ? false : true)
			}
		case "move":
			moveItemsToList(selected: selection)
		default:
			break
		}
	}

	func state(for menuItem: String, with id: UUID) -> UIMenuElement.State {
		guard menuItem == "strikethrough" else {
			return .off
		}
		return cache.strikethroughItems.contains(id) ? .on : .off
	}
}

// MARK: - ToolbarDelegate
extension ContentPresenter: ToolbarDelegate {

	func didSelectToolbarItem(with identifier: String, state: UIMenuElement.State) {
		guard let selection = view?.selection else {
			return
		}

		switch identifier {
		case "new":
			createItem(with: .init(title: ""))
		case "delete":
			Task {
				try? await interactor.deleteItems(with: selection)
			}
		case "strikethrough":
			Task {
				try? await interactor.strikeThroughItems(with: selection, flag: state == .on ? false : true)
			}
		case "move":
			moveItemsToList(selected: nil)
		default:
			break
		}
	}

	func getToolbarModel() -> ContentToolbarModel {
		let selection = view?.selection ?? []
		let state = state(for: selection)

		return ContentToolbarModel(
			secondary: .init(
				isEnadled: !selection.isEmpty,
				state: ["strikethrough": state]
			),
			status: .init(title: selection.isEmpty ? "Select Items" : "\(selection.count) Item Selected")
		)
	}
}

// MARK: - TableDelegate
extension ContentPresenter: TableDelegate {

	func table(didUpdateSelection selection: [UUID]) {

		// MARK: - Toolbar

		let model = getToolbarModel()
		view?.display(toolbar: model)
	}
}

import UIKit

// MARK: - Helpers
extension ContentPresenter {

	func createItem(with model: ItemEditorModel) {
		coordinator?.presentItemEditor(with: model) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = Item.Properties(title: newModel.title, isStrikethrough: false)
				try? await self?.interactor.addItem(with: properties)
			}
		}
	}

	func moveItemsToList(selected: [UUID]?) {
		guard let selection = selected ?? view?.selection else {
			return
		}
		coordinator?.presentListPicker { [weak self] isSuccess, list in
			guard isSuccess else {
				return
			}
			Task {
				try? await self?.interactor.moveItems(with: selection, to: list)
			}
		}
	}

	func editItem(with id: UUID, model: ItemEditorModel) {
		coordinator?.presentItemEditor(with: model) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = Item.Properties(title: newModel.title, isStrikethrough: false)
				try? await self?.interactor.setText(properties.title, for: id)
			}
		}
	}

	func state(for selection: [UUID]) -> UIMenuElement.State {
		let intersection = cache.strikethroughItems.intersection(selection)

		return switch intersection.count {
		case 0:					.off
		case selection.count:	.on
		default:				.mixed
		}
	}
}

extension ContentPresenter {

	struct Cache {
		var strikethroughItems: Set<UUID> = []
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(items: [Item]) {
		let models = items.map {
			ContentItem(uuid: $0.id, title: $0.title, isStrikethrough: $0.isStrikethrough)
		}

		// MARK: - Cache

		cache.strikethroughItems = Set(
			items.filter { $0.isStrikethrough }
				.map(\.id)
		)

		view?.display(newItems: models)

		// MARK: - Toolbar

		let model = getToolbarModel()
		view?.display(toolbar: model)
	}

	func present(content: Content) {
		switch content {
		case .all:
			view?.displayTitle(title: "All")
		case let .list(list):
			view?.displayTitle(title: list.name)
		}
	}
}
