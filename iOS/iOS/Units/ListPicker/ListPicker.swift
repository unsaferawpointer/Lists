//
//  ListPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import SwiftUI

struct ListPicker {

	var model: ListPickerModel

	var completion: (Bool, UUID?) -> Void

	// MARK: - Initialization

	init(model: ListPickerModel, completion: @escaping (Bool, UUID?) -> Void) {
		self.model = model
		self.completion = completion
	}
}

// MARK: - View
extension ListPicker: View {

	var body: some View {
		NavigationStack {
			Form {
				ForEach(model.lists) { list in
					HStack {
						Label(list.name, systemImage: list.properties.icon?.iconName ?? "list")
						Spacer()
						if model.selected == list.id {
							Image(systemName: "checkmark")
								.foregroundColor(.blue)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						model.selected = list.id
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
						completion(false, nil)
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
//	ListPicker(model: <#ListPickerModel#>)
//}
