//
//  SidebarView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI

struct SidebarView: View {

	@State var documents: [DocumentItem] =
	[
		.init(name: "Today", iconName: "doc.text"),
		.init(name: "Backlog", iconName: "doc.text"),
		.init(name: "Покупки", iconName: "doc.text"),
		.init(name: "Инвентаризация", iconName: "doc.text")
	]

	@State var presentedDocument: DocumentItem? = nil

	@State var selection: Set<UUID> = []

	#if os(iOS)
	@State var editMode: EditMode = .inactive
	#endif

	var body: some View {
			List(selection: $selection) {
				ForEach(documents, id: \.id) { document in
					NavigationLink(value: document.id) {
						HStack(alignment: .firstTextBaseline) {
							Image(systemName: document.iconName)
								.foregroundStyle(.secondary)
							Text(document.name)
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
					withAnimation {
						documents.removeAll(where: { selection.contains($0.id) })
					}
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
				#if os(iOS)
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
							presentedDocument = .init(name: "New Document", iconName: "doc.text")
						} label: {
							Label("Add Item", systemImage: "plus")
						}
					}
				}
				#elseif os(macOS)
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
				#endif
			}
	}
}

#Preview {
	SidebarView()
}
