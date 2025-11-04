//
//  ListPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import SwiftUI

struct ListPicker: View {

	var model: ListPickerModel

	var completion: (Bool, UUID?) -> Void

	// MARK: - Local State

	@State var selected: UUID?

	init(model: ListPickerModel, completion: @escaping (Bool, UUID?) -> Void) {
		self.model = model
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Picker("", selection: $selected) {
					Text("None")
						.tag(nil as UUID?)
					ForEach(model.lists) { list in
						Label(list.name, systemImage: list.properties.icon?.iconName ?? "folder")
							.tag(list.id)
					}
				}
				.pickerStyle(.inline)
				.labelsHidden()
				.listItemTint(.primary)
			}
			.navigationTitle("Select List")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion(true, selected)
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
			model.provider.fetchData()
		}
		.onAppear {
			model.provider.fetchData()
		}
	}
}

//#Preview {
//	ListPicker(model: <#ListPickerModel#>)
//}
