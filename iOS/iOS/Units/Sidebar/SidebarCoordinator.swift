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
	func presentFilterEditor(with properties: Filter.Properties, andTags tags: Set<UUID>, completion: @escaping (Bool, Filter.Properties, Set<UUID>) -> Void)
	func openWindow(for payload: ContentPayload)
}

@MainActor
final class SidebarCoordinator {

	let router: MasterRoutable & MainRoutable

	let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(router: MasterRoutable & MainRoutable, persistentContainer: NSPersistentContainer) {
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

	func presentFilterEditor(with properties: Filter.Properties, andTags tags: Set<UUID>, completion: @escaping (Bool, Filter.Properties, Set<UUID>) -> Void) {
		let tagsProvider = ModelsProvider<Tag>(container: DefaultContainer(base: persistentContainer), request: TagsRequest(uuid: nil))
		let model = FilterEditorModel(properties: properties, selectedTags: tags, tagsProvider: tagsProvider)
		let view = FilterEditor(model: model) { [weak self] isSuccess, newModel, tags in
			self?.router.dismissInMasterViewController()
			completion(isSuccess, newModel, tags)
		}
		router.presentInMaster(viewController: UIHostingController(rootView: view))
	}

	func openWindow(for payload: ContentPayload) {
		router.openWindow(info: ["content": payload.rawValue])
	}
}
