//
//  ContentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class ContentAssembly {

	static func build(payload: ContentPayload, storage: StorageProtocol, persistentContainer: NSPersistentContainer) -> UIViewController {

		let coreDataProvider = CoreDataProvider<ItemEntity>(
			persistentContainer: persistentContainer,
			sortDescriptors:
				[
					NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
					NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
				],
			predicate: payload.value
		)
		let provider = DataProvider(coreDataProvider: coreDataProvider, converter: ItemsConverter())

		let interactor = ContentInteractor(payload: payload, storage: storage, dataProvider: provider)
		let presenter = ContentPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = ContentViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		let router = Router()
		router.viewController = viewController

		presenter.router = router

		return viewController
	}
}
