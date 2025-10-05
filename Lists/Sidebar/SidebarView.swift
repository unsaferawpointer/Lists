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
	@Query(sort: \ListEntity.timestamp, animation: .default) private var lists: [ListEntity]

	@FocusState private var focusedItem: PersistentIdentifier?
	@State var selection: Selection = .all

	@State var presented: ListEntity?

	@State var isPresented: Bool = false

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
								.focused($focusedItem, equals: list.id)
						}
						.listItemTint(.primary)
						.listRowSeparator(.hidden)
						.contextMenu {
							buildContextMenu(for: list)
						}
						.tag(Selection.list(id: list.id))
					}
					.onDelete(perform: deleteItems)
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
			ToolbarItem {
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
			let newItem = ListEntity(timestamp: Date(), name: "New Item", icon: .noIcon)
			modelContext.insert(newItem)
			selection = .list(id: newItem.id)
			focusedItem = newItem.id
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
}

#Preview {
	SidebarView()
		.modelContainer(for: ItemEntity.self, inMemory: true)
}
