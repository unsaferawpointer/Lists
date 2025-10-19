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

	// MARK: - Initialization

	init(interactor: ContentInteractorProtocol) {
		self.interactor = interactor
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
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

}
