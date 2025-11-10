//
//  ContentRouter.swift
//  iOS
//
//  Created by Anton Cherkasov on 10.11.2025.
//

import UIKit

final class ContentRouter {

	private let window: UIWindow

	// MARK: - Initialization

	init(window: UIWindow) {
		self.window = window
	}
}

// MARK: - ContentRoutable
extension ContentRouter: ContentRoutable {

	func showContent(viewController: UIViewController) {
		window.rootViewController = UINavigationController(rootViewController: viewController)
		window.makeKeyAndVisible()
	}

	func dismissInDetailsViewController() {
		content?.presentedViewController?.dismiss(animated: true)
	}

	func presentInDetails(viewController: UIViewController) {
		content?.present(viewController, animated: true)
	}
}

extension ContentRouter {

	var content: UIViewController? {
		guard let navigationController = window.rootViewController as? UINavigationController else {
			return nil
		}
		return navigationController.topViewController
	}
}
