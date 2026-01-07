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

		let predicate: ItemsPredicate

		// MARK: - Initialization

		init(predicate: ItemsPredicate) {
			self.predicate = predicate
		}
	}
}

// MARK: - Computed Properties
extension ContentView.Model {

	var moveDisabled: Bool {
		guard case .inProject = predicate.type else {
			return true
		}
		return false
	}

	func completionSources(for selected: Set<PersistentIdentifier>, in items: [Item]) -> [Binding<Bool>] {
		return items.filter { item in
			selected.contains(item.id)
		}.map { item in
			Binding {
				item.isCompleted
			} set: { newValue in
				item.isCompleted = newValue
			}
		}
	}

	func showEditButton(selected: Set<PersistentIdentifier>) -> Bool {
		return !selected.isEmpty
	}
}

import SwiftUI

// MARK: - Public Interface
extension ContentView.Model {

	func addItem(in modelContext: ModelContext, to items: [Item], with text: String) {
		let newItem = Item(uuid: .init(), text: text)

		if let last = items.last {
			newItem.index = last.index + 1
		}

		switch predicate.type {
		case .all:
			break
		case let .inProject(id):
			if let project = modelContext.model(for: id) as? Project {
				newItem.project = project
			}
		case .filter:
			break
		}

		modelContext.insert(newItem)
	}

	func deleteItems(_ items: Set<PersistentIdentifier>, in modelContext: ModelContext) {
		try? modelContext.transaction {
			for id in items {
				guard let item = modelContext.model(for: id) as? Item else {
					continue
				}
				modelContext.delete(item)
			}
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

	func updateItem(_ item: Item, with text: String) {
		item.text = text
	}

	func moveItems(_ items: [Item], indices: IndexSet, to target: Int) {
		var modificated = items
		modificated.move(fromOffsets: indices, toOffset: target)
		for (index, item) in modificated.enumerated() {
			item.index = index
		}
	}
}
