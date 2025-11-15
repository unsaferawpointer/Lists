//
//  TagPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import SwiftUI

struct TagPicker {

	var model: TagPickerModel

	var completion: (Bool, Set<UUID>) -> Void

	// MARK: - Initialization

	init(model: TagPickerModel, completion: @escaping (Bool, Set<UUID>) -> Void) {
		self.model = model
		self.completion = completion
	}
}

// MARK: - View
extension TagPicker: View {

	var body: some View {
		NavigationStack {
			Form {
				ForEach(model.tags) { tag in
					HStack {
						Label(tag.name, systemImage: tag.properties.icon?.iconName ?? "tag")
						Spacer()
						if model.selected.contains(tag.id) {
							Image(systemName: "checkmark")
								.foregroundColor(.blue)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						toggleSelection(for: tag.id)
					}
				}
			}
			.navigationTitle("Select Tag")
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

// MARK: - Helpers
private extension TagPicker {

	func toggleSelection(for item: UUID) {
		if model.selected.contains(item) {
			model.selected.remove(item)
		} else {
			model.selected.insert(item)
		}
	}
}

//#Preview {
//	TagPicker(model: <#TagPickerModel#>)
//}
