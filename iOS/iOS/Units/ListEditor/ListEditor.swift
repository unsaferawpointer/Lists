//
//  ListEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import SwiftUI

struct ListEditor: View {

	@State var name: String = ""

	var completion: ((Bool, ListEditorModel) -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var isValid: Bool {
		validator.validate(name: name)
	}

	init(model: ListEditorModel, completion: ((Bool, ListEditorModel) -> Void)? = nil) {
		self._name = State(initialValue: model.name)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter Name", text: $name)
						.focused($inFocus)
						.onAppear {
							inFocus = true
						}
				} header: {
					Text("Name")
				} footer: {
					if !isValid {
						Text("Invalid Name")
					}
				}

			}
			.formStyle(.grouped)
			.navigationTitle("Edit List")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion?(true, .init(name: name))
					}
					.disabled(!isValid)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						completion?(false, .init(name: ""))
					}
				}
			}
		}
	}
}

#Preview {
	ListEditor(model: .init(name: "Default List"))
}
