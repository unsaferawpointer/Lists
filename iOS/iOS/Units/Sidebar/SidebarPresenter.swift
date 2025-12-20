//
//  SidebarPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

@MainActor
protocol SidebarPresenterProtocol: AnyObject {
	func present(filters: [Object<Filter.Properties>])
	func present(lists: [Object<List.Properties>])
}

final class SidebarPresenter {

	var interactor: SidebarInteractorProtocol?

	weak var view: SidebarView?

	var coordinator: SidebarCoordinatable?

	// MARK: - Cache

	private var filtersCache: [UUID: Filter.Properties] = [:]

	// MARK: - Initialization

	init(interactor: SidebarInteractorProtocol) {
		self.interactor = interactor
	}
}

// MARK: - SidebarViewDelegate
extension SidebarPresenter: SidebarViewDelegate {

	func viewDidLoad() {
		view?.displayPinned(
			newItems:
				[
					.init(id: .all, iconName: "square.grid.2x2", title: "All"),
					.init(id: .tags, iconName: "tag", title: "Tags")
				],
			select: .all
		)
		try? interactor?.fetchLists()
		try? interactor?.fetchFilters()
	}

	func contextMenu(didSelect menuItem: String, for item: UUID) {
		switch menuItem {
		case "edit-project":
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
		case "edit-filter":
			guard let properties = filtersCache[item] else {
				return
			}
			coordinator?.presentFilterEditor(with: properties, andTags: []) { isSuccess, newProperties, tags in
				guard isSuccess else { return }
				Task { @MainActor [weak self] in
					try? await self?.interactor?.updateFilter(id: item, properties: newProperties, andTags: tags)
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
		let properties = Filter.Properties(name: "")
		coordinator?.presentFilterEditor(with: properties, andTags: []) { [weak self] isSuccess, newProperties, tags in
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

	func present(filters: [Object<Filter.Properties>]) {

		// MARK: - Update Cache
		filtersCache.removeAll()
		for filter in filters {
			filtersCache[filter.id] = filter.properties
		}

		let items = filters.map {
			NavigationItem(
				id: .filter(id: $0.id),
				iconName: $0.properties.icon?.iconName ?? "list",
				title: $0.properties.name
			)
		}
		view?.displayFilters(newItems: items)
	}

	func present(lists: [Object<List.Properties>]) {
		let items = lists.map {
			NavigationItem(
				id: .list(id: $0.id),
				iconName: $0.properties.icon?.iconName ?? "list",
				title: $0.properties.name
			)
		}
		view?.display(newItems: items)
	}
}
