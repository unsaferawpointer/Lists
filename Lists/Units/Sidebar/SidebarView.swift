//
//  SidebarView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftData
import SwiftUI

struct SidebarView: View {

	@Environment(\.modelContext) private var modelContext
	@Query(animation: .default) private var documents: [DocumentEntity]

	@State var presentedDocument: DocumentItem? = nil

	@State var selection: Set<UUID> = []

	#if os(iOS)
	@State var editMode: EditMode = .inactive
	#endif

	var body: some View {
			List(selection: $selection) {
				ForEach(documents) { document in
					NavigationLink(value: document.uuid) {
						HStack(alignment: .firstTextBaseline) {
							Image(systemName: "doc.text")
								.foregroundStyle(.secondary)
							Text(document.name ?? "")
						}
					}
					.listRowSeparator(.hidden)
				}
			}
			#if os(iOS)
			.environment(\.editMode, $editMode)
			#endif
			.contextMenu(forSelectionType: UUID.self) { selection in
				Button(role: .destructive) {
					delete(ids: selection)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
			.navigationTitle("Documents")
			.navigationDestination(for: UUID.self) { id in
				DocumentView()
			}
			.sheet(item: $presentedDocument) { document in
				DocumentDetailsView(document: document)
			}
			.toolbar {
				buildToolbar()
			}
	}
}

// MARK: - Helpers
private extension SidebarView {

	#if os(iOS)
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			Button(editMode.isEditing ? "Done" : "Edit") {
				withAnimation {
					editMode = editMode.isEditing ? .inactive : .active
				}
			}
		}
		ToolbarItem(placement: .bottomBar) {
			Spacer()
		}
		if editMode != .active {
			ToolbarItem(placement: .bottomBar) {
				Button {
					addItem()
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
	#elseif os(macOS)
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		ToolbarItem {
			Spacer()
		}
		ToolbarItem(placement: .primaryAction) {
			Button {
				presentedDocument = .init(name: "New Document", iconName: "doc.text")
			} label: {
				Label("Add Item", systemImage: "plus")
			}
		}
	}
	#endif
}

// MARK: - Helpers
private extension SidebarView {

	func addItem() {
		withAnimation {
			let newItem = DocumentEntity(name: "New Document")
			modelContext.insert(newItem)
		}
	}

	func delete(ids: Set<UUID>) {
		withAnimation {
			let models = documents.filter { ids.contains($0.uuid) }
			for model in models {
				modelContext.delete(model)
			}
		}
	}
}

#Preview {
	NavigationStack {
		SidebarView()
	}
}
