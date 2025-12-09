//
//  TagsEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import SwiftUI

struct TagsEditor {

	var model: TagsEditorModel

	// MARK: - Initialization

	init(model: TagsEditorModel) {
		self.model = model
	}
}

// MARK: - View
extension TagsEditor: View {

	var body: some View {
		NavigationStack {
			SwiftUI.List {
				ForEach(model.tags) { tag in
					Label(tag.name, systemImage: "tag")
						.listItemTint(.primary)
				}
			}
			.listStyle(.inset)
			.navigationTitle("Tags")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .bottomBar) {
					Spacer()
				}
				ToolbarItem(placement: .bottomBar) {
					Button {
						withAnimation {
							model.newTag()
						}
					} label: {
						Image(systemName: "plus")
					}

				}
			}
		}
		.task {
			try? await model.provider.fetchData()
		}
	}
}

//#Preview {
//	TagsEditor()
//}
