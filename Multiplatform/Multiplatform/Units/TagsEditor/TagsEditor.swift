//
//  TagsEditor.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI
import SwiftData

struct TagsEditor: View {

	@Environment(\.modelContext) private var modelContext
	@Query private var tags: [Tag]

	@State var selection: Set<UUID> = []

	var body: some View {
		List(selection: $selection) {
			ForEach(tags, id: \.uuid) { tag in
				Label(tag.title, systemImage: "tag")
					.listItemTint(.primary)
			}
		}
		.contextMenu(forSelectionType: UUID.self) { selected in
			Divider()
			Button(role: .destructive) {
				deleteTags(selected: selected)
			} label: {
				Text("Delete")
			}
		}
		.listStyle(.inset)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				EditButton()
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button(action: addTag) {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

// MARK: - Helpers
private extension TagsEditor {

	func addTag() {
		withAnimation {
			let newTag = Tag(uuid: .init(), title: "New Tag")
			modelContext.insert(newTag)
		}
	}

	func deleteTags(selected: Set<UUID>) {
		withAnimation {
			for tag in tags.filter( { selected.contains($0.uuid)} ) {
				modelContext.delete(tag)
			}
		}
	}
}

#Preview {
	TagsEditor()
		.modelContainer(for: Tag.self, inMemory: true)
}
