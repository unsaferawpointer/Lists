//
//  SidebarAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit
import CoreData

final class SidebarAssembly {

	static func build(router: MasterRoutable & MainRoutable, persistentContainer: NSPersistentContainer, selectionDelegate: SelectionDelegate) -> UIViewController {

		let listProvider = ModelsProvider<List>(container: DefaultContainer(base: persistentContainer), request: ListsRequest(uuid: nil))
		let filtersProvider = ModelsProvider<Filter>(container: DefaultContainer(base: persistentContainer), request: FilterRequest(uuid: nil))

		let storage = Storage(container: persistentContainer)

		let interactor = SidebarInteractor(storage: storage, listProvider: listProvider, filtersProvider: filtersProvider)
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
