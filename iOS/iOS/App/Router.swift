//
//  Router.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import UIKit
import SwiftUI

protocol Routable {
	func presentListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void)
	func presentItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void)
}

final class Router {

	weak var viewController: UIViewController?
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
}
