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
				self?.editItem(with: first, properties: item.properties)
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
			setTags(selected: selection)
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
			createItem(with: .init(title: "", isStrikethrough: false, tags: []))
		case "delete":
			Task {
				try? await interactor.deleteItems(with: selection)
			}
		case "strikethrough":
			Task {
				try? await interactor.strikeThroughItems(with: selection, flag: state == .on ? false : true)
			}
		case "move":
			setTags(selected: nil)
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

	func createItem(with properties: Item.Properties) {
		coordinator?.presentItemEditor(with: properties) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = Item.Properties(title: newModel.title, isStrikethrough: false, tags: [])
				try? await self?.interactor.addItem(with: properties)
			}
		}
	}

	func setTags(selected: [UUID]?) {
		guard let selection = selected ?? view?.selection, let first = selection.first else {
			return
		}

		let tags = cache.tags[first] ?? []
		coordinator?.presentTagPicker(tags: tags) { [weak self] isSuccess, tags in
			guard isSuccess else {
				return
			}
			Task {
				try? await self?.interactor.setTags(items: [first], tags: tags)
			}
		}
	}

	func editItem(with id: UUID, properties: Item.Properties) {
		coordinator?.presentItemEditor(with: properties) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = Item.Properties(title: newModel.title, isStrikethrough: false, tags: [])
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
		var tags: [UUID: Set<UUID>] = [:]
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(items: [Item]) {
		let models = items.map {
			ContentItem(uuid: $0.id, title: $0.title, subtitle: $0.properties.tags.map(\.name).joined(separator: " | "), isStrikethrough: $0.isStrikethrough)
		}

		// MARK: - Cache
		cache.strikethroughItems = Set(
			items.filter { $0.isStrikethrough }
				.map(\.id)
		)
		var tags: [UUID: Set<UUID>] = [:]
		for item in items {
			tags[item.id] = Set(item.properties.tags.map(\.id))
		}
		cache.tags = tags

		view?.display(newItems: models)

		// MARK: - Toolbar

		let model = getToolbarModel()
		view?.display(toolbar: model)
	}

	func present(content: Content) {
		switch content {
		case .all:
			view?.displayTitle(title: "All")
		case let .tag(tag):
			view?.displayTitle(title: tag.name)
		}
	}
}
