//
//  ContentView.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {

	var list: ListEntity?

	@Environment(\.modelContext) private var modelContext
	@Query(sort: \ItemEntity.timestamp, animation: .default) private var items: [ItemEntity]

	@State var selection: Set<PersistentIdentifier> = []

	@State var presented: ItemEntity?

	@State var isPresented: Bool = false

	// MARK: - Initialization

	init(list: ListEntity?) {

		self.list = list
		let id = list?.id

		let predicate = #Predicate<ItemEntity> { item in
			item.list?.id == id
		}

		self._items = Query(
			filter: predicate,
			sort: \ItemEntity.timestamp,
			order: .forward,
			animation: .default
		)
	}

	var body: some View {
		List(selection: $selection) {
			ForEach(items) { item in
				ItemCell(item: item)
					.listRowSeparator(.visible)
			}
		}
		.listStyle(.inset)
		.overlay {
			if items.isEmpty {
				ContentUnavailableView(
					"No Items",
					systemImage: "square.dashed",
					description: Text("To add a new item, tap the '+' button")
				)
			}
		}
		.contextMenu(forSelectionType: PersistentIdentifier.self) { selected in
			if selected.count == 1 {
				Button {
					self.presented = items.first(where: { selected.contains($0.id) })
				} label: {
					Label("Edit...", systemImage: "square.and.pencil")
				}
				Divider()
				Button(role: .destructive) {
					deleteItems(selected)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			} else if !selected.isEmpty {
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
		.sheet(item: $presented) { item in
			ItemEditor(item: item, list: list)
				.presentationDetents([.medium, .large])
						.presentationDragIndicator(.visible)
						.presentationBackground(.regularMaterial)
						.presentationCornerRadius(25)
						.presentationBackgroundInteraction(.enabled(upThrough: .medium))
		}
		.sheet(isPresented: $isPresented) {
			ItemEditor(item: nil, list: list)
		}
		.navigationTitle(list?.name ?? "All")
		#if os(macOS)
		.navigationSplitViewColumnWidth(min: 180, ideal: 200)
		#endif
		.toolbar {
			#if os(iOS)
			ToolbarItem(placement: .navigationBarTrailing) {
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
			#else
			ToolbarItem(placement: .primaryAction) {
				Button(action: addItem) {
					Label("Add Item", systemImage: "plus")
				}
			}
			#endif
		}
	}
}

// MARK: - Helpers
private extension ContentView {

	func addItem() {
		withAnimation {
			isPresented = true
		}
	}

	func deleteItems(_ ids: Set<PersistentIdentifier>) {
		withAnimation {
			let deleted = items.filter {
				ids.contains($0.id)
			}
			for item in deleted {
				modelContext.delete(item)
			}
		}
	}
}

#Preview {
	ContentView(list: nil)
		.modelContainer(for: ItemEntity.self, inMemory: true)
}
