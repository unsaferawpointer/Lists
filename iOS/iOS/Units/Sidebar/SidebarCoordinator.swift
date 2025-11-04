//
//  SidebarCoordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import CoreData

import UIKit
import SwiftUI

@MainActor
protocol SidebarCoordinatable {
	func presentListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void)
}

@MainActor
final class SidebarCoordinator {

	let router: MasterRoutable

	let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(router: MasterRoutable, persistentContainer: NSPersistentContainer) {
		self.router = router
		self.persistentContainer = persistentContainer
	}
}

// MARK: - SidebarCoordinatable
extension SidebarCoordinator: SidebarCoordinatable {

	func presentListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void) {
		let view = ListEditor(model: model) { [weak self] isSuccess, newModel in
			self?.router.dismissInMasterViewController()
			completion(isSuccess, newModel)
		}
		router.presentInMaster(viewController: UIHostingController(rootView: view))
	}
}
