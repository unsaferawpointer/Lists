//
//  SidebarAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit

final class SidebarAssembly {

	static func build(storage: StorageProtocol) -> UIViewController {

		let interactor = SidebarInteractor(storage: storage)
		let presenter = SidebarPresenter(interactor: interactor)
		interactor.presenter = presenter

		let viewController = SidebarViewController()
		viewController.delegate = presenter
		presenter.view = viewController

		return viewController
	}
}
