//
//  SidebarAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class SidebarAssembly {

	static func build(storage: StorageProtocol, persistentContainer: NSPersistentContainer, selectionDelegate: SelectionDelegate) -> UIViewController {

		let coreDataProvider = CoreDataProvider<ListEntity>(
			persistentContainer: persistentContainer,
			sortDescriptors: [NSSortDescriptor(keyPath: \ListEntity.creationDate, ascending: true)],
			predicate: nil
		)
		let provider = DataProvider(coreDataProvider: coreDataProvider, converter: ListsConverter())

		let interactor = SidebarInteractor(storage: storage, provider: provider)
		let presenter = SidebarPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = SidebarViewController()
		viewController.delegate = presenter
		viewController.selectionDelegate = selectionDelegate
		presenter.view = viewController

		let router = Router()
		router.viewController = viewController

		presenter.router = router

		return viewController
	}
}
