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
		let dataProvider = DataProvider(container: persistentContainer)

		var interactor: ContentInteractorProtocol = switch payload {
		case .all:
			ContentInteractor(
				payload: payload,
				dataManager: Database(container: persistentContainer),
				itemsProvider: CommonItemsProvider(request: .init(), dataProvider: dataProvider)
			)
		case .list(let id):
			ContentInteractor(
				payload: payload,
				dataManager: Database(container: persistentContainer),
				itemsProvider: ListItemsProvider(id: id, dataProvider: dataProvider)
			)
		case .filter(let id):
			ContentInteractor(
				payload: payload,
				dataManager: Database(container: persistentContainer),
				itemsProvider: FilteredItemsProvider(id: id, dataProvider: dataProvider)
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
