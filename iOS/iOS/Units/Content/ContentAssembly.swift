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
	static func build(router: ContentRoutable, payload: ContentPayload, persistentContainer: NSPersistentContainer) -> UIViewController {

		let storage = Storage(container: persistentContainer)

		let interactor = ContentInteractor(
			payload: payload,
			storage: storage,
			contentProvider: ContentProvider(payload: payload, container: DefaultContainer(base: persistentContainer))
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
