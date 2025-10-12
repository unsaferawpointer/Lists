//
//  SidebarView.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI
import SwiftData

struct SidebarView: View {

	@Environment(\.modelContext) private var modelContext
	@Query private var lists: [ListEntity]

	// MARK: - Local State

	@State private var selection: Selection = .all

	@State private var presented: ListEntity?

	@State private var isPresented: Bool = false

	init() {
		let predicate: Predicate<ListEntity> = #Predicate{ list in
			list.isHidden == false
		}

		let sortByTimestamp = SortDescriptor(\ListEntity.timestamp)
		let sortByOffset = SortDescriptor(\ListEntity.offset)

		self._lists = Query(
			filter: predicate,
			sort: [sortByOffset, sortByTimestamp],
			animation: .default
		)
	}

	var body: some View {
		List {
			NavigationLink {
				ContentView(list: nil)
			} label: {
				Label("All", systemImage: "square.grid.2x2")
			}
			.listRowSeparator(.hidden)
			.tag(Selection.all)

			Section("Library") {
				if lists.isEmpty {
					ContentUnavailableView(
						"No Items",
						systemImage: "square.dashed",
						description: Text("To add a new list, tap the '+' button")
					)
				} else {
					ForEach(lists, id:\.id) { list in
						NavigationLink {
							ContentView(list: list)
						} label: {
							ListCell(list: list)
						}
						.listRowSeparator(.hidden)
						.contextMenu {
							buildContextMenu(for: list)
						}
						.tag(Selection.list(id: list.id))
					}
					.onDelete(perform: deleteItems)
					.onMove { indices, target in
						moveItem(indices, to: target)
					}
				}
			}
		}
		.listStyle(.sidebar)
		.sheet(item: $presented) { list in
			ListEditor(list: list)
		}
		.sheet(isPresented: $isPresented) {
			ListEditor(list: nil)
		}
		.onAppear {
			self.selection = .all
		}
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

// MARK: - Nested data structs
extension SidebarView {

	enum Selection: Hashable {
		case all
		case list(id: PersistentIdentifier)
	}
}

private extension SidebarView {

	@ViewBuilder
	func buildContextMenu(for list: ListEntity) -> some View {
		Button {
			self.presented = list
		} label: {
			Label("Edit...", systemImage: "square.and.pencil")
		}
		Divider()
		Button(role: .destructive) {
			deleteItem(list.id)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
}

// MARK: - Helpers
private extension SidebarView {

	func addItem() {
		withAnimation {
			isPresented = true
		}
	}

	func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(lists[index])
			}
		}
	}

	func deleteItem(_ id: PersistentIdentifier) {
		withAnimation {
			guard let index = lists.firstIndex(where: { $0.id == id}) else {
				return
			}
			modelContext.delete(lists[index])
		}
	}

	func moveItem(_ indices: IndexSet, to target: Int) {
		withAnimation {
			var modificated = lists.enumerated().map(\.offset)
			modificated.move(fromOffsets: indices, toOffset: target)

			for (offset, index) in modificated.enumerated() {
				lists[index].offset = offset
			}
		}
	}
}

#Preview {
	SidebarView()
		.modelContainer(for: ItemEntity.self, inMemory: true)
}
