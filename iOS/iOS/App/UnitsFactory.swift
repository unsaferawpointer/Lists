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
	func buildTagEditor(with model: TagEditorModel, completion: @escaping (Bool, TagEditorModel) -> Void) -> UIViewController
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

	func buildTagEditor(with model: TagEditorModel, completion: @escaping (Bool, TagEditorModel) -> Void) -> UIViewController {
		let view = TagEditor(model: model, completion: completion)
		return UIHostingController(rootView: view)
	}
	
	func buildItemEditor(with model: ItemEditorModel, completion: @escaping (Bool, ItemEditorModel) -> Void) -> UIViewController {
		fatalError()
	}
}
