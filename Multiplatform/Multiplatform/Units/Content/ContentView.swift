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

	@State var selection: Set<UUID> = []

	@State var tagsPickerIsPresented: Bool = false

	var body: some View {
		List(selection: $selection) {
			ForEach(items, id: \.uuid) { item in
				VStack {
					Text(item.text)
						.strikethrough(item.isCompleted)
					if !item.tags.isEmpty {
						Text(tags.map(\.title).joined(separator: " | "))
					}
				}
			}
		}
		.contextMenu(forSelectionType: UUID.self) { selected in
			Button("Mark As Completed") {
				updateItems(selected: selected, isCompleted: true)
			}
			Button("Mark As Incomplete") {
				updateItems(selected: selected, isCompleted: false)
			}
			Divider()
			Button("Tags...", systemImage: "tag") {
				self.tagsPickerIsPresented = true
			}
			Divider()
			Button(role: .destructive) {
				deleteItems(selected: selected)
			} label: {
				Text("Delete")
			}
		}
		.listStyle(.inset)
		.sheet(isPresented: $tagsPickerIsPresented) {
			TagsPicker(
				selection: .init(get: {
					guard let first = items.first(where: { selection.contains($0.uuid) }) else {
						return []
					}
					return Set(first.tags.map(\.uuid))
				}, set: { newValue in
					guard let first = items.first(where: { selection.contains($0.uuid) }) else {
						return
					}
					first.tags = tags.filter { newValue.contains($0.uuid) }
				})
			)
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
			let newItem = Item(uuid: .init(), text: "New Item")
			modelContext.insert(newItem)
		}
	}

	func deleteItems(selected: Set<UUID>) {
		withAnimation {
			for item in items.filter( { selected.contains($0.uuid)} ) {
				modelContext.delete(item)
			}
		}
	}

	func updateItems(selected: Set<UUID>, isCompleted: Bool) {
		withAnimation {
			for item in items.filter( { selected.contains($0.uuid)} ) {
				item.isCompleted = isCompleted
			}
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(for: Item.self, inMemory: true)
}
