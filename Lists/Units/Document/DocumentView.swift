//
//  DocumentView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI

struct DocumentView: View {

	@State var items: [ListItem] =
	[
		.init(text: "Закрыть спринт"),
		.init(text: "Купить книгу"),
		.init(text: "Починить кроссовки"),
		.init(
			text: "Закрыть спринт",
			subitems:
				[
					.init(text: "Закрыть спринт"),
					.init(text: "Купить книгу"),
					.init(text: "Починить кроссовки"),
					.init(
						text: "Закрыть спринт",
						subitems:
							[
								.init(text: "Закрыть спринт"),
								.init(text: "Купить книгу"),
								.init(text: "Закрыть спринт"),
							]
					),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
				]
		),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
	]

	@State var selection: Set<UUID> = []

	@State var presentedItem: ListItem? = nil

	var body: some View {
		List(items, children: \.subitems, selection: $selection) { item in
			Text(item.text)
		}
		.listStyle(.inset)
		.contextMenu(forSelectionType: UUID.self) { selection in
			guard selection.count > 1 else {
				return Button("Edit...") {
					self.presentedItem = items.first(where: { selection.contains($0.id) })
				}
			}
			return Button("Delete") {

			}
		} primaryAction: { selection in
			Button("Delete") {

			}
		}
		.sheet(item: $presentedItem) { item in
			ItemDetailsView(item: item)
		}
		.navigationTitle("Backlog")
		.toolbar {
			ToolbarItem {
				EditButton()
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button {

				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	DocumentView()
}
