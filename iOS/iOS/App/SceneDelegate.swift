//
//  SceneDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder {

	private var coordinator: (any Coordinatable)?
}

// MARK: - UIWindowSceneDelegate
extension SceneDelegate: UIWindowSceneDelegate {

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}

		if
			let userActivity = connectionOptions.userActivities.first,
			let info = userActivity.userInfo as? [String: String],
			let content = info["content"],
			let payload = ContentPayload(rawValue: content)
		{
			let coordinator = ContentCoordinator(
				payload: payload,
				router: ContentRouter(window: UIWindow(windowScene: windowScene)),
				persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer
			)
			self.coordinator = coordinator
			coordinator.start()
		} else if let userActivity = session.stateRestorationActivity {
			fatalError()
		} else {
			let coordinator = MainCoordinator(
				router: MainRouter(window: UIWindow(windowScene: windowScene)),
				persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer
			)
			self.coordinator = coordinator
			coordinator.start()
		}
	}
}
