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

	private typealias Selection = SidebarModel.Selection

	#if os(iOS)
	@State private var editMode: EditMode = .inactive
	#endif

	@Bindable private var model = SidebarModel()

	// MARK: - Initialization

	init() {
		self._lists = Storage.listsQuery()
	}

	var body: some View {
		List(selection: $model.selection) {
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
					.onDelete { indices in
						withAnimation {
							model.deleteItems(offsets: indices, in: modelContext, lists: lists)
						}
					}
					.onMove { indices, target in
						withAnimation {
							model.moveItem(indices, to: target, lists: lists)
						}
					}
				}
			}
		}
		#if os(iOS)
		.environment(\.editMode, $editMode)
		.navigationLinkIndicatorVisibility(editMode == .active ? .hidden : .visible)
		#endif
		.listStyle(.sidebar)
		.sheet(item: $model.presented) { list in
			ListEditor(list: list, with: lists.indices.last ?? 0)
		}
		.sheet(isPresented: $model.isPresented) {
			ListEditor(list: nil, with: lists.indices.last ?? 0)
		}
		#if os(macOS)
		.navigationSplitViewColumnWidth(min: 180, ideal: 200)
		#endif
		.toolbar {
			#if os(iOS)
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					withAnimation {
						editMode = editMode == .active ? .inactive : .active
					}
				} label: {
					Text(editMode == .inactive ? "Edit" : "Done")
				}

			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					model.addItem()
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
			#else
			ToolbarItem(placement: .primaryAction) {
				Button {
					withAnimation {
						model.addItem()
					}
				} label: {
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
		Button {
			withAnimation {
				model.presented = list
			}
		} label: {
			Label("Edit...", systemImage: "square.and.pencil")
		}
		Divider()
		Button(role: .destructive) {
			withAnimation {
				model.deleteItem(list.id, in: modelContext, lists: lists)
			}
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
}

#Preview {
	SidebarView()
		.modelContainer(for: ItemEntity.self, inMemory: true)
}
