//
//  ContentCoordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 03.11.2025.
//

import CoreData

import UIKit
import SwiftUI

@MainActor
protocol ContentCoordinatable {
	func presentItemEditor(with properties: Item.Properties, completion: @escaping (Bool, Item.Properties) -> Void)
	func presentTagPicker(completion: @escaping (Bool, Set<UUID>) -> Void)
}

@MainActor
final class ContentCoordinator {

	private let router: ContentRoutable

	private let persistentContainer: NSPersistentContainer

	private let payload: ContentPayload

	// MARK: - Initialization

	init(
		payload: ContentPayload,
		router: ContentRoutable,
		persistentContainer: NSPersistentContainer
	) {
		self.payload = payload
		self.router = router
		self.persistentContainer = persistentContainer
	}
}

// MARK: - Coordinatable
extension ContentCoordinator: Coordinatable {

	func start() {
		let content = ContentAssembly.build(router: router, payload: payload, persistentContainer: persistentContainer)
		router.showContent(viewController: content)
	}
}

// MARK: - ContentCoordinatable
extension ContentCoordinator: ContentCoordinatable {

	func presentTagPicker(completion: @escaping (Bool, Set<UUID>) -> Void) {
		let provider = ModelsProvider<Tag>(container: DefaultContainer(base: persistentContainer), request: TagsRequest(uuid: nil))

		let model = TagPickerModel(selected: [], provider: provider)
		let view = TagPicker(model: model) { [weak self] isSuccess, selected in
			self?.router.dismissInDetailsViewController()
			completion(isSuccess, selected)
		}
		router.presentInDetails(viewController: UIHostingController(rootView: view))
	}

	func presentItemEditor(with properties: Item.Properties, completion: @escaping (Bool, Item.Properties) -> Void) {
		let view = ItemEditor(properties: properties) { [weak self] isSuccess, newModel in
			self?.router.dismissInDetailsViewController()
			completion(isSuccess, newModel)
		}

		router.presentInDetails(viewController: UIHostingController(rootView: view))
	}
}
