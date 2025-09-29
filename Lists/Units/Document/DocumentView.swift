//
//  DocumentView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI

struct DocumentView: View {

	var model: DocumentModel = DocumentModel()

	@State var selection: Set<UUID> = []

	@State var presentedItem: ListItem? = nil

	var body: some View {
		List(model.items, children: \.subitems, selection: $selection) { item in
			Text(item.text)
		}
		.listStyle(.inset)
		.contextMenu(forSelectionType: UUID.self) { selection in
			guard selection.count > 1 else {
				return Button("Edit...") {
					self.presentedItem = model.items.first(where: { selection.contains($0.id) })
				}
			}
			return Button("Delete") {
				model.deleteItems(with: selection)
			}
		}
		.sheet(item: $presentedItem) { item in
			ItemDetailsView(item: item)
		}
		.navigationTitle("Backlog")
		.toolbar {
			#if os(iOS)
			ToolbarItem {
				EditButton()
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					self.presentedItem = .init(text: "New Item")
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
			#elseif os(macOS)
			ToolbarItem(placement: .automatic) {
				Button {
					self.presentedItem = .init(text: "New Item")
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
			#endif
		}
	}
}

#Preview {
	DocumentView()
}
