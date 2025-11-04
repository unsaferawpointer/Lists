//
//  UnitsFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 03.11.2025.
//

import CoreData

import UIKit
import SwiftUI

protocol UnitsFactoryProtocol {
	func buildListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void) -> UIViewController
	func buildItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void) -> UIViewController
}

final class UnitsFactory {

	private let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
}

// MARK: - UnitsFactoryProtocol
extension UnitsFactory: UnitsFactoryProtocol {

	func buildListEditor(with model: ListEditorModel, completion: @escaping (Bool, ListEditorModel) -> Void) -> UIViewController {
		let view = ListEditor(model: model, completion: completion)
		return UIHostingController(rootView: view)
	}
	
	func buildItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void) -> UIViewController {
		let view = ItemEditor(model: model, completion: completion)
		return UIHostingController(rootView: view)
	}
}
