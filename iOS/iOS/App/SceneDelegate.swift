//
//  SceneDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder {

	private var coordinator: Coordinator?
}

// MARK: - UIWindowSceneDelegate
extension SceneDelegate: UIWindowSceneDelegate {

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}

		let coordinator = Coordinator(
			router: CoordinatorRouter(window: UIWindow(windowScene: windowScene)),
			persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer
		)
		self.coordinator = coordinator
		coordinator.start()
	}
}
