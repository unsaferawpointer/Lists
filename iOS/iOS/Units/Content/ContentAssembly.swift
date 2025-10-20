//
//  ContentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class ContentAssembly {

	static func build(id: UUID?, storage: StorageProtocol, persistentContainer: NSPersistentContainer) -> UIViewController {

		let predicate: NSPredicate? = if let uuid = id {
			NSPredicate(format: "list.uuid == %@", argumentArray: [uuid])
		} else {
			nil
		}

		let coreDataProvider = CoreDataProvider<ItemEntity>(
			persistentContainer: persistentContainer,
			sortDescriptors: [NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)],
			predicate: predicate
		)
		let provider = DataProvider(coreDataProvider: coreDataProvider, converter: ItemsConverter())

		let interactor = ContentInteractor(id: id, storage: storage, dataProvider: provider)
		let presenter = ContentPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = ContentViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		return viewController
	}
}
