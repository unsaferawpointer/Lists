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
	func presentItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void)
	func presentListPicker(completion: @escaping (Bool, UUID?) -> Void)
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

	func presentListPicker(completion: @escaping (Bool, UUID?) -> Void) {
		let provider = ModelsProvider<List>(container: DefaultContainer(base: persistentContainer), request: ListsRequest(uuid: nil))

		let model = ListPickerModel(provider: provider)
		let view = ListPicker(model: model) { [weak self] isSuccess, selected in
			self?.router.dismissInDetailsViewController()
			completion(isSuccess, selected)
		}
		router.presentInDetails(viewController: UIHostingController(rootView: view))
	}

	func presentItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void) {

		let view = ItemEditor(model: model) { [weak self] isSuccess, newModel in
			self?.router.dismissInDetailsViewController()
			completion(isSuccess, newModel)
		}

		router.presentInDetails(viewController: UIHostingController(rootView: view))
	}
}
