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

	@State var isPresentedItemEditor: Bool = false

	@State var presentedItemForTagsPicker: Item?

	let model: Model

	// MARK: - Initialization

	init(predicate: ItemsPredicate) {
		self.model = .init(predicate: predicate)
		self._items = Query(filter: predicate.predicate, sort: \.index, animation: .default)
	}

	var body: some View {
		List(selection: $selection) {
			ForEach(items) { item in
				HStack(spacing: 16) {
					Circle()
						.foregroundStyle(.quaternary)
						.frame(width: 4, height: 4)
					VStack(alignment: .leading, spacing: 2) {
						Text(item.text)
							.foregroundStyle(item.isCompleted ? .secondary : .primary)
							.strikethrough(item.isCompleted)
						if !item.tags.isEmpty {
							Text(item.tags.map(\.title).joined(separator: " | "))
								.foregroundStyle(.secondary)
								.font(.caption2)
						}
					}
				}
				.contextMenu {
					buildMenu(selected: [item.id])
				}
				.moveDisabled(model.moveDisabled)
			}
			.onMove { indices, target in
				model.moveItems(items, indices: indices, to: target)
			}
		}
		.listStyle(.inset)
		.contextMenu(forSelectionType: PersistentIdentifier.self) { selected in
			buildMenu(selected: selected)
		}
		.sheet(item: $presentedItemForTagsPicker) { item in
			TagsPicker(selected: Set(item.tags.map(\.id))) { newTags in
				item.tags = tags.filter { newTags.contains($0.id) }
			}
		}
		.sheet(isPresented: $isPresentedItemEditor) {
			ItemEditor(title: "New Item", model: .init(text: "")) { newModel in
				withAnimation {
					model.addItem(in: modelContext, to: items, with: newModel.text)
				}
			}
		}
		.sheet(item: $presentedItem) { item in
			ItemEditor(title: "Edit Item", model: .init(text: item.text)) { newModel in
				withAnimation {
					model.updateItem(item, with: newModel.text)
				}
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

// MARK: - View Builders
private extension ContentView {

	@ViewBuilder
	func buildMenu(selected: Set<PersistentIdentifier>) -> some View {
		if let first = selected.first {
			Button("Edit...", systemImage: "pencil") {
				self.presentedItem = items.first(where: { $0.id == first })
			}
			Divider()
		}
		Toggle(sources: model.completionSources(for: selected, in: items), isOn: \.self) {
			Text("Completed")
		}
		Divider()
		if let first = selected.first {
			Button("Tags...", systemImage: "tag") {
				self.presentedItemForTagsPicker = items.first(where: { $0.id == first })
			}
			Divider()
		}
		Button(role: .destructive) {
			deleteItems(selected: selected)
		} label: {
			Text("Delete")
		}
	}
}

// MARK: - Helpers
private extension ContentView {

	func addItem() {
		withAnimation {
			self.isPresentedItemEditor = true
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
