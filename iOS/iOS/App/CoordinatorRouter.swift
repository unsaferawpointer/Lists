//
//  CoordinatorRouter.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import UIKit

protocol ApplicationRoutable {
	func setupWindow(primaryViewController: UIViewController, secondaryViewController: UIViewController)
	func showDetail(viewController: UIViewController)
}

protocol ContentRoutable {
	func presentInDetails(viewController: UIViewController)
	func dismissInDetailsViewController()
}

protocol MasterRoutable {
	func presentInMaster(viewController: UIViewController)
	func dismissInMasterViewController()
}

final class CoordinatorRouter {

	var window: UIWindow

	// MARK: - Initialization

	init(window: UIWindow) {
		self.window = window
	}
}

// MARK: - ApplicationRoutable
extension CoordinatorRouter: ApplicationRoutable {

	func setupWindow(primaryViewController: UIViewController, secondaryViewController: UIViewController) {

		let splitViewController = UISplitViewController(style: .doubleColumn)

		splitViewController.setViewController(
			UINavigationController(rootViewController: primaryViewController),
			for: .primary
		)
		splitViewController.setViewController(
			UINavigationController(rootViewController: secondaryViewController),
			for: .secondary
		)

		splitViewController.preferredDisplayMode = .oneBesideSecondary
		splitViewController.displayModeButtonVisibility = .automatic
		splitViewController.primaryBackgroundStyle = .sidebar

		window.rootViewController = splitViewController
		window.makeKeyAndVisible()
	}

	func showDetail(viewController: UIViewController) {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return
		}
		splitViewController.showDetailViewController(viewController, sender: nil)
	}
}

// MARK: - MasterRoutable
extension CoordinatorRouter: MasterRoutable {

	func dismissInMasterViewController() {
		let container = self.viewController(for: .primary)
		container?.presentedViewController?.dismiss(animated: true)
	}

	func presentInMaster(viewController: UIViewController) {
		let container = self.viewController(for: .primary)
		container?.present(viewController, animated: true)
	}
}

// MARK: - ContentRoutable
extension CoordinatorRouter: ContentRoutable {

	func dismissInDetailsViewController() {
		let container = self.viewController(for: .secondary)
		container?.presentedViewController?.dismiss(animated: true)
	}

	func presentInDetails(viewController: UIViewController) {
		let container = self.viewController(for: .secondary)
		container?.present(viewController, animated: true)
	}
}

// MARK: - Computed Properties
extension CoordinatorRouter {

	func viewController(for column: UISplitViewController.Column) -> UIViewController? {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return nil
		}
		let navigationController = splitViewController.viewController(for: column) as? UINavigationController
		return navigationController?.topViewController
	}
}
