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

	var selection: Selection?

	var presented: ListEntity?

	var isPresented: Bool = false
}

extension SidebarModel {

	func addItem() {
		isPresented = true
	}

	func deleteItems(offsets: IndexSet, in context: ModelContext, lists: [ListEntity]) {
		withAnimation {
			for index in offsets {
				context.delete(lists[index])
			}
		}
	}

	func deleteItem(_ id: PersistentIdentifier, in context: ModelContext, lists: [ListEntity]) {
		withAnimation {
			guard let index = lists.firstIndex(where: { $0.id == id}) else {
				return
			}
			context.delete(lists[index])
		}
	}

	func moveItem(_ indices: IndexSet, to target: Int, lists: [ListEntity]) {
		withAnimation {
			var modificated = lists.enumerated().map(\.offset)
			modificated.move(fromOffsets: indices, toOffset: target)

			for (offset, index) in modificated.enumerated() {
				lists[index].offset = offset
			}
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
