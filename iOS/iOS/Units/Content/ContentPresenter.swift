//
//  ContentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentPresenterProtocol: AnyObject {
	func present(items: [Item])
}

final class ContentPresenter {

	var interactor: ContentInteractorProtocol

	weak var view: ContentView?

	var router: Routable?

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

	func contextMenuSelected(menuItem: String, with selection: [UUID]) {
		switch menuItem {
		case "edit":
			fatalError()
		case "delete":
			Task { @MainActor in
				try? await interactor.deleteItems(with: selection)
				let items = try? await interactor.fetchItems()
				let models = items?.map {
					ContentItem(uuid: $0.id, title: $0.title, isStrikethrough: $0.isStrikethrough)
				}
				view?.display(newItems: models ?? [])
			}
		case "strikethrough":
			Task { @MainActor in
				try? await interactor.strikeThroughItems(with: selection)
			}
		default:
			break
		}
	}

	func didTapAddButton() {
		let model = ItemEditorModel(title: "")
		router?.presentItemEditor(with: model) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor in
				let properties = Item.Properties(title: newModel.title, isStrikethrough: false)
				try? await self?.interactor.addItem(with: properties)
			}
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(items: [Item]) {
		let models = items.map {
			ContentItem(uuid: $0.id, title: $0.title, isStrikethrough: $0.isStrikethrough)
		}
		view?.display(newItems: models)
	}
}
