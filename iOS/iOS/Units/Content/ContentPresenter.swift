//
//  ContentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentPresenterProtocol: AnyObject { }

final class ContentPresenter {

	var interactor: ContentInteractorProtocol

	weak var view: ContentView?

	// MARK: - Local State

	private var editedItem: UUID?

	// MARK: - Initialization

	init(interactor: ContentInteractorProtocol) {
		self.interactor = interactor
	}

	deinit {
		
	}
}

// MARK: - ContentViewDelegate
extension ContentPresenter: ContentViewDelegate {

	func viewDidLoad() {
		Task { @MainActor in
			let items = try? await interactor.fetchItems()
			let models = items?.map {
				ContentItem(uuid: $0.id, title: $0.title)
			}
			view?.display(newItems: models ?? [])
		}
	}

	func editorDidCommit(text: String) {
		guard let id = editedItem else {
			let item = Item(uuid: UUID(), title: text)
			Task { @MainActor in
				try? await interactor.addItem(item)
				let items = try? await interactor.fetchItems()
				let models = items?.map {
					ContentItem(uuid: $0.id, title: $0.title)
				}
				view?.display(newItems: models ?? [])
				view?.scroll(to: item.id)
				view?.displayEditor(.init(text: "", iconName: "arrow.up", inFocus: false))
			}
			return
		}
		Task { @MainActor in
			try? await interactor.setText(text, for: id)
			editedItem = nil
			view?.displayEditor(.init(text: "", iconName: "arrow.up", inFocus: false))
			let items = try? await interactor.fetchItems()
			let models = items?.map {
				ContentItem(uuid: $0.id, title: $0.title)
			}
			view?.display(newItems: models ?? [])
		}
	}

	func contextMenuSelected(menuItem: String, with selection: [UUID]) {
		switch menuItem {
		case "edit":
			Task { @MainActor in
				guard let first = selection.first else {
					return
				}
				editedItem = selection.first
				guard let item = try? await interactor.fetchItem(with: first) else {
					return
				}
				view?.displayEditor(.init(text: item.title, iconName: "checkmark", inFocus: true))
			}
		case "delete":
			Task { @MainActor in
				try? await interactor.deleteItems(with: selection)
				let items = try? await interactor.fetchItems()
				let models = items?.map {
					ContentItem(uuid: $0.id, title: $0.title)
				}
				view?.display(newItems: models ?? [])
			}
		default:
			break
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

}
