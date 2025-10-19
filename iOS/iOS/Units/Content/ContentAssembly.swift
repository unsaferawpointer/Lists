//
//  ContentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit

final class ContentAssembly {

	static func build(id: UUID?, storage: StorageProtocol) -> UIViewController {

		let interactor = ContentInteractor(id: id, storage: storage)
		let presenter = ContentPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = ContentViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		return viewController
	}
}
