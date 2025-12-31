//
//  ContentView + Model.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 31.12.2025.
//

import Foundation
import SwiftData

extension ContentView {

	@Observable
	final class Model {

		@ObservationIgnored
		let predicate: ItemsPredicate

		// MARK: - Initialization

		init(predicate: ItemsPredicate) {
			self.predicate = predicate
		}
	}
}

// MARK: - Public Interface
extension ContentView.Model {

	func addItem(in modelContext: ModelContext) {
		let newItem = Item(uuid: .init(), text: "New Item")
		switch predicate {
		case .all:
			break
		case let .inProject(id):
			guard let project = modelContext.model(for: id) as? Project else {
				return
			}
			newItem.project = project
		}
		modelContext.insert(newItem)
	}

	func deleteItems(_ items: Set<PersistentIdentifier>, in modelContext: ModelContext) {
		for id in items {
			guard let item = modelContext.model(for: id) as? Item else {
				continue
			}
			modelContext.delete(item)
		}
	}

	func updateItems(selected: Set<PersistentIdentifier>, isCompleted: Bool, in modelContext: ModelContext) {
		for id in selected {
			guard let item = modelContext.model(for: id) as? Item else {
				continue
			}
			item.isCompleted = isCompleted
		}
	}
}
