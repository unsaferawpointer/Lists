//
//  TagsEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import SwiftUI

struct TagsEditor {

	var model: TagsEditorModel

	@State var presentedTag: Tag?

	@State var selection: Set<UUID> = []

	// MARK: - Initialization

	init(model: TagsEditorModel) {
		self.model = model
	}
}

// MARK: - View
extension TagsEditor: View {

	var body: some View {
		NavigationStack {
			SwiftUI.List(selection: $selection) {
				ForEach(model.tags) { tag in
					Label(tag.name, systemImage: "tag")
						.listItemTint(.primary)
				}
			}
			.listStyle(.inset)
			.backgroundExtensionEffect(isEnabled: false)
			.contextMenu(forSelectionType: UUID.self) { selected in
				Button {
					model.deleteTags(with: Array(selected))
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
			.navigationTitle("Tags")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					EditButton()
				}
				ToolbarItem(placement: .bottomBar) {
					Spacer()
				}
				ToolbarItem(placement: .bottomBar) {
					Button {
						withAnimation {
							presentedTag = .init(uuid: .init(), properties: .init(name: ""))
						}
					} label: {
						Image(systemName: "plus")
					}
				}
			}
		}
		.sheet(item: $presentedTag) { tag in
			TagEditor(properties: tag.properties) { isSuccess, properties in
				guard isSuccess else {
					return
				}
				model.newTag(with: properties)
			}
		}
		.task {
			await model.fetchTags()
		}
	}
}

//#Preview {
//	TagsEditor()
//}
