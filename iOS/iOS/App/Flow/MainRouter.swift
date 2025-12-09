//
//  MainRouter.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import UIKit

protocol MainRoutable {
	func showWindow()
	func showDetail(viewController: UIViewController, wrappedInNavigationController: Bool)
	func openWindow(info: [String: String])
}

protocol ContentRoutable {
	func showContent(viewController: UIViewController)
	func presentInDetails(viewController: UIViewController)
	func dismissInDetailsViewController()
}

protocol MasterRoutable {
	func showMaster(viewController: UIViewController)
	func presentInMaster(viewController: UIViewController)
	func dismissInMasterViewController()
}

final class MainRouter {

	var window: UIWindow

	// MARK: - Initialization

	init(window: UIWindow) {
		self.window = window
		self.window.rootViewController = UISplitViewController(style: .doubleColumn)
	}
}

// MARK: - MainRoutable
extension MainRouter: MainRoutable {

	func showWindow() {
		window.makeKeyAndVisible()
	}

	func openWindow(info: [String: String]) {
		guard let currentScene = window.windowScene else {
			return
		}

		let options = UIScene.ActivationRequestOptions()
		options.requestingScene = currentScene

		let activity = NSUserActivity(activityType: "content-window")
		activity.userInfo = info

		let request = UISceneSessionActivationRequest(
			role: .windowApplication,
			userActivity: activity,
			options: options
		)
		UIApplication.shared.activateSceneSession(for: request) { _ in }
	}

	func showDetail(viewController: UIViewController, wrappedInNavigationController: Bool) {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return
		}
		guard wrappedInNavigationController else {
			splitViewController.showDetailViewController(viewController, sender: nil)
			return
		}
		splitViewController.showDetailViewController(UINavigationController(rootViewController: viewController), sender: nil)
	}
}

// MARK: - MasterRoutable
extension MainRouter: MasterRoutable {

	func showMaster(viewController: UIViewController) {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return
		}
		splitViewController.setViewController(
			UINavigationController(rootViewController: viewController),
			for: .primary
		)
	}

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
extension MainRouter: ContentRoutable {

	func showContent(viewController: UIViewController) {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return
		}
		splitViewController.setViewController(
			UINavigationController(rootViewController: viewController),
			for: .secondary
		)
	}

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
extension MainRouter {

	func viewController(for column: UISplitViewController.Column) -> UIViewController? {
		guard let splitViewController = window.rootViewController as? UISplitViewController else {
			return nil
		}
		let navigationController = splitViewController.viewController(for: column) as? UINavigationController
		return navigationController?.topViewController
	}
}
