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
	@Query(animation: .default) private var lists: [ListEntity]

	@FocusState private var focusedItem: PersistentIdentifier?
	@State var selection: PersistentIdentifier?

	var body: some View {
		List(selection: $selection) {
			NavigationLink(value: 0) {
				Label("All", systemImage: "square.grid.2x2")
			}
			.listRowSeparator(.hidden)

			Section("Library") {
				ForEach(lists, id:\.id) { list in
					NavigationLink {
						ListView()
					} label: {
						ListCell(list: list)
							.focused($focusedItem, equals: list.id)
					}
					.listItemTint(.primary)
					.listRowSeparator(.hidden)
					.contextMenu {
						buildContextMenu(for: list)
					}
				}
				.onDelete(perform: deleteItems)
			}
		}
		.listStyle(.sidebar)
		.navigationTitle("Lists")
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

private extension SidebarView {

	@ViewBuilder
	func buildContextMenu(for list: ListEntity) -> some View {
		Picker("Icon", selection: Binding(get: {
			list.icon ?? .textPage
		}, set: { newValue in
			list.icon = newValue
		})) {
			ForEach(Icon.allCases, id: \.self) { icon in
				Image(systemName: icon.iconName)
					.tag(icon)
			}
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
			selection = newItem.id
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
