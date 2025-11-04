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

	let router: ContentRoutable

	let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(router: ContentRoutable, persistentContainer: NSPersistentContainer) {
		self.router = router
		self.persistentContainer = persistentContainer
	}
}

// MARK: - ContentCoordinatable
extension ContentCoordinator: ContentCoordinatable {

	func presentListPicker(completion: @escaping (Bool, UUID?) -> Void) {
		let provider = ListsObserver(container: DefaultContainer(base: persistentContainer), request: .init(fetchLimit: nil, uuid: nil))

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
