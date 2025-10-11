//
//  ContentView.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI
import SwiftData

struct ContentView {

	// MARK: - Enviroment

	@Environment(\.modelContext) private var modelContext

	// MARK: - Data

	var list: ListEntity?

	@Query(animation: .default) private var items: [ItemEntity]

	// MARK: - Internal State

	@State private var selection: Set<PersistentIdentifier> = []

	@State private var presented: ItemEntity?

	@State private var isPresented: Bool = false

	// MARK: - Calculated Propertiers

	func itemBindings(for ids: Set<PersistentIdentifier>) -> [Binding<Bool>] {
		items
			.filter { ids.contains($0.id) }
			.map { item in
				Binding<Bool>(
					get: { item.strikeThrough },
					set: { newValue in item.strikeThrough = newValue }
				)
			}
	}

	// MARK: - Initialization

	init(list: ListEntity?) {

		self.list = list

		let predicate: Predicate<ItemEntity>? = {
			if let list {
				let id = list.id
				return #Predicate<ItemEntity> { item in
					item.list?.id == id
				}
			} else {
				return nil
			}
		}()

		let sortByTimestamp = SortDescriptor(\ItemEntity.timestamp)
		let sortByStrikethrough = SortDescriptor(\ItemEntity.strikeThrough)

		self._items = Query(
			filter: predicate,
			sort: [sortByStrikethrough, sortByTimestamp],
			animation: .default
		)
	}
}

// MARK: - View
extension ContentView: View {

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
				makeMenu(for: selected)
			} else if !selected.isEmpty {
				makeMenu(for: selected)
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
				.presentationDetents([.medium])
				.presentationDragIndicator(.visible)
		}
		.sheet(isPresented: $isPresented) {
			ItemEditor(item: nil, list: list)
				.presentationDetents([.medium])
				.presentationDragIndicator(.visible)
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

// MARK: - Helpersa
private extension ContentView {

	@ViewBuilder
	func makeMenu(for ids: Set<PersistentIdentifier>) -> some View {
		Toggle(sources: itemBindings(for: ids), isOn: \.self) {
			Label("Strikethrough", systemImage: "strikethrough")
		}
		Divider()
		Button(role: .destructive) {
			deleteItems(ids)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
}

#Preview {
	ContentView(list: nil)
		.modelContainer(for: ItemEntity.self, inMemory: true)
}

extension Bool: @retroactive Comparable {

	public static func < (lhs: Bool, rhs: Bool) -> Bool {
		// Реализация по умолчанию: false < true
		return !lhs && rhs
	}
}
