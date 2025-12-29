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
	@Query(sort: \Tag.creationDate, order: .forward, animation: .default) private var tags: [Tag]

	@State var selection: Set<UUID> = []

	@State private var editMode: EditMode = .inactive

	@State var presented: Tag?

	@State var isPresented: Bool = false

	var body: some View {
		List(selection: $selection) {
			ForEach(tags, id: \.uuid) { tag in
				HStack {
					if editMode == .inactive {
						Image(systemName: "tag")
					}
					Text(tag.title)
					Spacer()
				}
				.contextMenu {
					buildMenu(for: [tag.uuid])
				}
			}
		}
		.contextMenu(forSelectionType: UUID.self) { selected in
			buildMenu(for: selected)
		}
		.listStyle(.inset)
		.sheet(isPresented: $isPresented) {
			TagEditor(title: "New Tag", model: .init(name: "")) { newModel in
				withAnimation {
					let newTag = Tag(uuid: UUID(), title: newModel.name)
					modelContext.insert(newTag)
				}
			}
		}
		.sheet(item: $presented) { tag in
			TagEditor(title: "Edit Tag", model: .init(name: tag.title)) { newModel in
				tag.title = newModel.name
			}
		}
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
		.environment(\.editMode, $editMode)
	}
}

// MARK: - Helpers
private extension TagsEditor {

	@ViewBuilder
	func buildMenu(for selected: Set<UUID>) -> some View {
		if let first = selected.first, selected.count == 1 {
			Button("Edit...") {
				self.presented = tags.first(where: { $0.uuid == first })
			}
		}
		Divider()
		Button(role: .destructive) {
			deleteTags(selected: selected)
		} label: {
			Text("Delete")
		}
	}
}

// MARK: - Helpers
private extension TagsEditor {

	func addTag() {
		withAnimation {
			self.isPresented = true
		}
	}

	func deleteTags(selected: Set<UUID>) {
		withAnimation {
			editMode = .inactive
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
