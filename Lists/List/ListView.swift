//
//  ListView.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI
import SwiftData

struct ListView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \ItemEntity.timestamp, animation: .default) private var items: [ItemEntity]

	@State var selection: Set<PersistentIdentifier> = []

	var body: some View {
		List(selection: $selection) {
			ForEach(items) { item in
				ItemCell(item: item)
					.listRowSeparator(.visible)
			}
		}
		.listStyle(.inset)
		.contextMenu(forSelectionType: PersistentIdentifier.self) { selected in
			if !selected.isEmpty {
				Button {
					deleteItems(selected)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			} else {
				Button {
					addItem()
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
		#if os(macOS)
		.navigationSplitViewColumnWidth(min: 180, ideal: 200)
		#endif
		.toolbar {
			#if os(iOS)
			ToolbarItem(placement: .navigationBarTrailing) {
				EditButton()
			}
			#endif
			ToolbarItem {
				Button(action: addItem) {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

// MARK: - Helpers
private extension ListView {

	func addItem() {
		withAnimation {
			let newItem = ItemEntity(timestamp: Date(), title: "New Item", list: nil)
			modelContext.insert(newItem)
		}
	}

	func deleteItems(_ ids: Set<PersistentIdentifier>) {
		withAnimation {
			try? modelContext.delete(
				model: ItemEntity.self,
				where: #Predicate { ids.contains($0.id) }
			)
		}
	}
}

#Preview {
	ListView()
		.modelContainer(for: ItemEntity.self, inMemory: true)
}
