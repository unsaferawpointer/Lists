//
//  ContentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class ContentAssembly {

	@MainActor
	static func build(router: any ContentRoutable, payload: ContentPayload, persistentContainer: NSPersistentContainer) -> UIViewController {

		let storage = Storage(container: persistentContainer)

		var interactor: ContentInteractorProtocol = switch payload {
		case .all:
			ContentInteractor(
				payload: payload,
				storage: storage,
				contentProvider: ContentProvider(payload: payload, container: DefaultContainer(base: persistentContainer))
			)
		case .list(let id):
			ContentInteractor(
				payload: payload,
				storage: storage,
				contentProvider: ContentProvider(payload: payload, container: DefaultContainer(base: persistentContainer))
			)
		case .filter(let id):
			FilteredContent.Interactor(
				identifier: id,
				filterProvider: DataProvider<FilterEntity>(container: persistentContainer),
				itemsProvider: DataProvider<ItemEntity>(container: persistentContainer)
			)
		}

		let presenter = ContentPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = ContentViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		presenter.coordinator = ContentCoordinator(
			payload: payload,
			router: router,
			persistentContainer: persistentContainer
		)

		return viewController
	}
}
