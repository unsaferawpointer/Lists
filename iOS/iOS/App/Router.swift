//
//  Router.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import CoreData

import UIKit
import SwiftUI

protocol Routable {
	func presentListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void)
	func presentItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void)
	func presentListPicker(completion: @escaping (Bool, UUID?) -> Void)
}

final class Router {

	weak var viewController: UIViewController?

	weak var persistentContainer: NSPersistentContainer?
}

// MARK: - Routable
extension Router: Routable {

	func presentListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void) {
		let view = ListEditor(model: model) { [weak self] isSuccess, newModel in
			self?.viewController?.presentedViewController?.dismiss(animated: true)
			completion(isSuccess, newModel)
		}
		let presenting = UIHostingController(rootView: view)
		presenting.modalPresentationStyle = .formSheet

		viewController?.present(presenting, animated: true)
	}

	func presentItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void) {
		let view = ItemEditor(model: model) { [weak self] isSuccess, newModel in
			self?.viewController?.presentedViewController?.dismiss(animated: true)
			completion(isSuccess, newModel)
		}
		let presenting = UIHostingController(rootView: view)
		presenting.modalPresentationStyle = .formSheet

		viewController?.present(presenting, animated: true)
	}

	func presentListPicker(completion: @escaping (Bool, UUID?) -> Void) {

		guard let persistentContainer else {
			return
		}

		let coreDataProvider = CoreDataProvider<ListEntity>(
			persistentContainer: persistentContainer,
			sortDescriptors: [NSSortDescriptor(keyPath: \ListEntity.creationDate, ascending: true)],
			predicate: nil
		)
		let provider = DataProvider(coreDataProvider: coreDataProvider, converter: ListsConverter())

		let model = ListPickerModel(provider: provider)

		let view = ListPicker(model: model) { [weak self] isSuccess, list in
			self?.viewController?.presentedViewController?.dismiss(animated: true)
			completion(isSuccess, list)
		}

		let presenting = UIHostingController(rootView: view)
		presenting.modalPresentationStyle = .formSheet

		viewController?.present(presenting, animated: true)
	}
}
