//
//  SidebarModel.swift
//  Lists
//
//  Created by Anton Cherkasov on 12.10.2025.
//

import SwiftData
import SwiftUI

@Observable
final class SidebarModel {

	var selection: Selection? = .all

	var presented: ListEntity?

	var isPresented: Bool = false
}

extension SidebarModel {

	func addItem() {
		isPresented = true
	}

	func deleteItems(offsets: IndexSet, in context: ModelContext, lists: [ListEntity]) {
		let ids = offsets.map {
			lists[$0].id
		}
		Storage.deleteLists(ids, in: context)
	}

	func deleteItem(_ id: PersistentIdentifier, in context: ModelContext, lists: [ListEntity]) {
		Storage.deleteLists([id], in: context)
	}

	func moveItem(_ indices: IndexSet, to target: Int, lists: [ListEntity]) {
		var modificated = lists.enumerated().map(\.offset)
		modificated.move(fromOffsets: indices, toOffset: target)

		for (offset, index) in modificated.enumerated() {
			lists[index].offset = offset
		}
	}
}

// MARK: - Nested Data Structs
extension SidebarModel {

	enum Selection: Hashable {
		case all
		case list(id: PersistentIdentifier)
	}
}
