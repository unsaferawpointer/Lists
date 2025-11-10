//
//  MainCoordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 03.11.2025.
//

import UIKit
import CoreData

@MainActor
final class MainCoordinator {

	let router: MainRouter

	let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(router: MainRouter, persistentContainer: NSPersistentContainer) {
		self.router = router
		self.persistentContainer = persistentContainer
	}
}

// MARK: - Coordinatable
extension MainCoordinator: Coordinatable {

	func start() {
		let sidebar = SidebarAssembly.build(router: router, persistentContainer: persistentContainer, selectionDelegate: self)
		let content = ContentAssembly.build(router: router, payload: .all, persistentContainer: persistentContainer)

		router.showMaster(viewController: sidebar)
		router.showContent(viewController: content)
		router.showWindow()
	}
}

// MARK: - SelectionDelegate
extension MainCoordinator: SelectionDelegate {

	func didSelect(item: NavigationItem.ID) {
		let payload: ContentPayload = switch item {
		case .all:
			.all
		case let .list(id):
			.list(id: id)
		}

		let content = ContentAssembly.build(router: router, payload: payload, persistentContainer: persistentContainer)
		router.showDetail(viewController: content)
	}
}
