//
//  ContentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class ContentAssembly {

	static func build(router: ContentRoutable, payload: ContentPayload, persistentContainer: NSPersistentContainer) -> UIViewController {

		let itemsProvider = DataProvider(
			coreDataProvider: CoreDataProvider<ItemEntity>(
				persistentContainer: persistentContainer,
				sortDescriptors:
					[
						NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
						NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
					],
				predicate: payload.value
			),
			converter: ItemsConverter()
		)

		let listsProvider: DataProvider<List, ListEntity>? = if let listID = payload.listID {
			DataProvider(
				coreDataProvider: CoreDataProvider<ListEntity>(
					persistentContainer: persistentContainer,
					sortDescriptors: [NSSortDescriptor(keyPath: \ListEntity.creationDate, ascending: true)],
					predicate: NSPredicate(format: "uuid == %@", argumentArray: [listID]),
					fetchLimit: 1
				),
				converter: ListsConverter()
			)
		} else {
			nil
		}

		let storage = Storage(container: persistentContainer)

		let interactor = ContentInteractor(
			payload: payload,
			storage: storage,
			itemsProvider: itemsProvider,
			listsProvider: listsProvider
		)
		let presenter = ContentPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = ContentViewController()
		viewController.delegate = presenter
		presenter.view = viewController
		presenter.coordinator = ContentCoordinator(router: router, persistentContainer: persistentContainer)

		return viewController
	}
}
