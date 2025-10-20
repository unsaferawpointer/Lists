//
//  SidebarAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class SidebarAssembly {

	static func build(storage: StorageProtocol, persistentContainer: NSPersistentContainer) -> UIViewController {

		let coreDataProvider = CoreDataProvider<ListEntity>(
			persistentContainer: persistentContainer,
			sortDescriptors: [NSSortDescriptor(keyPath: \ListEntity.creationDate, ascending: true)]
		)
		let provider = DataProvider(coreDataProvider: coreDataProvider, converter: ListsConverter())

		let interactor = SidebarInteractor(storage: storage, provider: provider)
		let presenter = SidebarPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = SidebarViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		return viewController
	}
}
