//
//  SidebarPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarPresenterProtocol: AnyObject { }

final class SidebarPresenter {

	var interactor: SidebarInteractorProtocol?

	weak var view: SidebarView?

	// MARK: - Initialization

	init(interactor: SidebarInteractorProtocol) {
		self.interactor = interactor
	}
}

// MARK: - SidebarViewDelegate
extension SidebarPresenter: SidebarViewDelegate {

	func viewDidLoad() {
		Task { @MainActor in
			let lists = try? await interactor?.fetchLists() ?? []
			let items = convert(lists: lists ?? [])
			view?.display(newItems: items)
		}
	}

	func contextMenu(didSelect menuItem: String, for item: UUID) {
		switch menuItem {
		case "edit":
			break
		case "delete":
			interactor?.deleteList(with: item)
		default:
			break
		}
	}

}

// MARK: - SidebarPresenterProtocol
extension SidebarPresenter: SidebarPresenterProtocol { }

// MARK: - Helpers
private extension SidebarPresenter {

	func convert(lists: [List]) -> [NavigationItem] {
		lists.map { list in
			NavigationItem(id: .list(id: list.id), iconName: "star", title: list.name)
		}
	}
}
