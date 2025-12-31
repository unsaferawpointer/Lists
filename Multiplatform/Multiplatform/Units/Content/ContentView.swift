//
//  ContentView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {

	@Environment(\.modelContext) private var modelContext

	@Query private var items: [Item]
	@Query private var tags: [Tag]

	@State var selection: Set<PersistentIdentifier> = []

	@State var presentedItem: Item?

	let model: Model

	// MARK: - Initialization

	init(predicate: ItemsPredicate) {
		self.model = .init(predicate: predicate)
		self._items = Query(filter: predicate.predicate, sort: \.index, animation: .default)
	}

	var body: some View {
		List(selection: $selection) {
			ForEach(items) { item in
				VStack(alignment: .leading) {
					Text(item.text)
						.foregroundStyle(item.isCompleted ? .secondary : .primary)
						.strikethrough(item.isCompleted)
					if !item.tags.isEmpty {
						Text(item.tags.map(\.title).joined(separator: " | "))
					}
				}
			}
		}
		.contextMenu(forSelectionType: PersistentIdentifier.self) { selected in
			Button("Mark As Completed") {
				updateItems(selected: selected, isCompleted: true)
			}
			Button("Mark As Incomplete") {
				updateItems(selected: selected, isCompleted: false)
			}
			Divider()
			if let first = selection.first {
				Button("Tags...", systemImage: "tag") {
					self.presentedItem = items.first(where: { $0.id == first })
				}
				Divider()
			}
			Button(role: .destructive) {
				deleteItems(selected: selected)
			} label: {
				Text("Delete")
			}
		}
		.listStyle(.inset)
		.sheet(item: $presentedItem) { item in
			TagsPicker(selected: Set(item.tags.map(\.id))) { newTags in
				item.tags = tags.filter { newTags.contains($0.id) }
			}
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				EditButton()
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button(action: addItem) {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

// MARK: - Helpers
private extension ContentView {

	func addItem() {
		withAnimation {
			model.addItem(in: modelContext)
		}
	}

	func deleteItems(selected: Set<PersistentIdentifier>) {
		withAnimation {
			model.deleteItems(selected, in: modelContext)
		}
	}

	func updateItems(selected: Set<PersistentIdentifier>, isCompleted: Bool) {
		withAnimation {
			model.updateItems(selected: selected, isCompleted: isCompleted, in: modelContext)
		}
	}
}

#Preview {
	ContentView(predicate: .all)
		.modelContainer(for: Item.self, inMemory: true)
}
