//
//  SidebarPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarPresenterProtocol: AnyObject {
	func present(lists: [List])
	func present(filters: [Filter])
}

final class SidebarPresenter {

	var interactor: SidebarInteractorProtocol?

	weak var view: SidebarView?

	var coordinator: SidebarCoordinatable?

	// MARK: - Initialization

	init(interactor: SidebarInteractorProtocol) {
		self.interactor = interactor
	}
}

// MARK: - SidebarViewDelegate
extension SidebarPresenter: SidebarViewDelegate {

	func viewDidLoad() {
		Task { @MainActor in
			view?.displayPinned(
				newItems:
					[
						.init(id: .all, iconName: "square.grid.2x2", title: "All"),
						.init(id: .tags, iconName: "tag", title: "Tags")
					],
				select: .all
			)
			try? await interactor?.fetchLists()
			try? await interactor?.fetchFilters()
		}
	}

	func contextMenu(didSelect menuItem: String, for item: UUID) {
		switch menuItem {
		case "edit":
			Task { @MainActor in
				guard let list = try? await interactor?.list(for: item) else {
					return
				}
				let model = ListEditorModel(name: list.name, icon: list.properties.icon)
				coordinator?.presentListEditor(with: model) { [weak self] isSuccess, newModel in
					guard isSuccess else {
						return
					}
					Task { @MainActor [weak self] in
						let properties = List.Properties(name: newModel.name, icon: newModel.icon)
						try? await self?.interactor?.updateList(with: item, properties: properties)
					}
				}
			}
		case "new-window":
			coordinator?.openWindow(for: .list(id: item))
		case "delete":
			interactor?.deleteList(with: item)
		default:
			break
		}
	}

	func newList() {
		let model = ListEditorModel(name: "")
		coordinator?.presentListEditor(with: model) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = List.Properties(name: newModel.name, icon: newModel.icon)
				try? await self?.interactor?.addList(with: properties)
			}
		}
	}

	func newFilter() {
		let properties = Filter.Properties(name: "", tags: [])
		coordinator?.presentFilterEditor(with: properties) { [weak self] isSuccess, newProperties in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				try? await self?.interactor?.addFilter(with: newProperties)
			}
		}
	}

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) {
		Task {
			try? await interactor?.moveList(with: id, to: destination)
		}
	}

}

// MARK: - SidebarPresenterProtocol
extension SidebarPresenter: SidebarPresenterProtocol {

	func present(lists: [List]) {
		Task { @MainActor in
			let items = convert(lists: lists)
			view?.display(newItems: items)
		}
	}

	func present(filters: [Filter]) {
		Task { @MainActor in
			let items = convert(filters: filters)
			view?.displayFilters(newItems: items)
		}
	}
}

// MARK: - Helpers
private extension SidebarPresenter {

	func convert(filters: [Filter]) -> [NavigationItem] {
		filters.map { filter in
			NavigationItem(id: .filter(id: filter.id), iconName: filter.properties.icon?.iconName ?? "filter", title: filter.name)
		}
	}

	func convert(lists: [List]) -> [NavigationItem] {
		lists.map { list in
			NavigationItem(id: .list(id: list.id), iconName: list.properties.icon?.iconName ?? "list", title: list.name)
		}
	}
}
