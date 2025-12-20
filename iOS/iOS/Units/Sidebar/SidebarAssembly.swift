//
//  SidebarAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class SidebarAssembly {

	@MainActor
	static func build(router: MasterRoutable & MainRoutable, persistentContainer: NSPersistentContainer, selectionDelegate: SelectionDelegate) -> UIViewController {

		let providers = SidebarInteractor.Providers(
			lists: DataProvider(container: persistentContainer),
			filters: DataProvider(container: persistentContainer)
		)

		let interactor = SidebarInteractor(database: Database(container: persistentContainer), providers: providers)
		let presenter = SidebarPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = SidebarViewController()
		viewController.delegate = presenter
		viewController.selectionDelegate = selectionDelegate
		presenter.view = viewController
		presenter.coordinator = SidebarCoordinator(router: router, persistentContainer: persistentContainer)

		return viewController
	}
}
