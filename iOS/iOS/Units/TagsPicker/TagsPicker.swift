//
//  TagsPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import SwiftUI

struct TagsPicker {

	var model: TagsPickerModel

	var completion: (Bool, Set<UUID>) -> Void

	// MARK: - Initialization

	init(model: TagsPickerModel, completion: @escaping (Bool, Set<UUID>) -> Void) {
		self.model = model
		self.completion = completion
	}
}

// MARK: - View
extension TagsPicker: View {

	var body: some View {
		NavigationStack {
			Form {
				ForEach(model.tags) { tag in
					HStack {
						Label(tag.name, systemImage: tag.properties.icon?.iconName ?? "list")
						Spacer()
						if model.selected.contains(tag.id) {
							Image(systemName: "checkmark")
								.foregroundColor(.blue)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						if model.selected.contains(tag.id) {
							model.selected.remove(tag.id)
						} else {
							model.selected.insert(tag.id)
						}
					}
				}
			}
			.navigationTitle("Select List")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion(true, model.selected)
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						completion(false, [])
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
//	TagsPicker(model: <#TagsPickerModel#>)
//}
