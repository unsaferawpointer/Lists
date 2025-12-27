//
//  SidebarPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

@MainActor
protocol SidebarPresenterProtocol: AnyObject {
	func present(filters: [Object<Filter.Properties, Filter.Relationships>])
	func present(lists: [Object<List.Properties, List.Relationships>])
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

	func contextMenu(didSelect menuItem: String, for item: NavigationItem.ID) {
		switch menuItem {
		case "edit":
			switch item {
			case let .filter(id):
				coordinator?.presentFilterEditor(with: id)
			case let .list(id):
				guard let list = try? interactor?.list(for: id) else {
					return
				}
				let model = ListEditorModel(name: list.name, icon: list.properties.icon)
				coordinator?.presentListEditor(with: model) { [weak self] isSuccess, newModel in
					guard isSuccess else {
						return
					}
					let properties = List.Properties(name: newModel.name, icon: newModel.icon)
					try? self?.interactor?.updateList(with: id, properties: properties)
				}
			default:
				fatalError()
			}
		case "new-window":
			switch item {
			case .all:
				coordinator?.openWindow(for: .all)
			case let .filter(id):
				coordinator?.openWindow(for: .filter(id: id))
			case let .list(id):
				coordinator?.openWindow(for: .list(id: id))
			default:
				fatalError()
			}
		case "delete":
			switch item {
			case let .filter(id):
				try? interactor?.deleteFilter(with: id)
			case let .list(id):
				try? interactor?.deleteList(with: id)
			default:
				fatalError()
			}
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
			let properties = List.Properties(name: newModel.name, icon: newModel.icon)
			try? self?.interactor?.addList(with: properties)
		}
	}

	func newFilter() {
		coordinator?.presentFilterEditor(with: nil)
	}

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) {
		Task {
			try? await interactor?.moveList(with: id, to: destination)
		}
	}

}

// MARK: - SidebarPresenterProtocol
extension SidebarPresenter: SidebarPresenterProtocol {

	func present(filters: [Object<Filter.Properties, Filter.Relationships>]) {

		// MARK: - Update Cache
		filtersCache.removeAll()
		for filter in filters {
			filtersCache[filter.id] = filter.properties
		}
		let items = SidebarItemsFactory().items(filters: filters)
		view?.displayFilters(newItems: items)
	}

	func present(lists: [Object<List.Properties, List.Relationships>]) {
		let items = SidebarItemsFactory().items(lists: lists)
		view?.display(newItems: items)
	}
}
