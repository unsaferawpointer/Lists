//
//  DocumentsView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI

struct DocumentsView: View {

	@State var documents: [DocumentItem] =
	[
		.init(name: "Today", iconName: "doc.text"),
		.init(name: "Backlog", iconName: "doc.text"),
		.init(name: "Покупки", iconName: "doc.text"),
		.init(name: "Инвентаризация", iconName: "doc.text")
	]

	@State var presentedDocument: DocumentItem? = nil

	var body: some View {
			List {
				ForEach(documents, id: \.id) { document in
					NavigationLink(value: document.id) {
						HStack(alignment: .firstTextBaseline) {
							Image(systemName: document.iconName)
							Text(document.name)
						}
					}
					.contextMenu {
						Button {
							self.presentedDocument = document
						} label: {
							Label("Edit...", systemImage: "pencil")
						}
						Divider()
						Button(role: .destructive) {
							withAnimation {
								documents.removeAll(where: { $0.id == document.id })
							}
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
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
				ToolbarItem(placement: .bottomBar) {
					Spacer()
				}
				ToolbarItem(placement: .bottomBar) {
					Button {
						presentedDocument = .init(name: "New Document", iconName: "doc.text")
					} label: {
						Label("Add Item", systemImage: "plus")
					}
				}
			}
	}
}

#Preview {
	DocumentsView()
}
