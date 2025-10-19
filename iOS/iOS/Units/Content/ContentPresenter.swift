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
				view?.displayEditor(.init(text: "", disabled: false))
			}
			return
		}
		Task { @MainActor in
			try? await interactor.setText(text, for: id)
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

}
