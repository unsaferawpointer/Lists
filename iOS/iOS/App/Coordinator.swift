//
//  Coordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 03.11.2025.
//

import Foundation
import CoreData

@MainActor
final class Coordinator {

	let router: CoordinatorRouter

	let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(router: CoordinatorRouter, persistentContainer: NSPersistentContainer) {
		self.router = router
		self.persistentContainer = persistentContainer
	}
}

extension Coordinator {

	func start() {
		let sidebar = SidebarAssembly.build(router: router, persistentContainer: persistentContainer, selectionDelegate: self)
		let content = ContentAssembly.build(router: router, payload: .all, persistentContainer: persistentContainer)

		router.setupWindow(primaryViewController: sidebar, secondaryViewController: content)
	}
}

// MARK: - SelectionDelegate
extension Coordinator: SelectionDelegate {

	func didSelect(item: NavigationItem) {
		let payload: ContentPayload = switch item.id {
		case .all:
			.all
		case let .list(id):
			.list(id: id)
		}

		let content = ContentAssembly.build(router: router, payload: payload, persistentContainer: persistentContainer)
		router.showDetail(viewController: content)
	}
}
