//
//  ListEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import SwiftUI

struct ListEditor: View {

	@State var model: ListEditorModel

	var completion: ((Bool, ListEditorModel) -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var validationResult: ListValidator.ValidationResult {
		validator.validate(name: model.name)
	}

	// MARK: - Initialization

	init(model: ListEditorModel, completion: ((Bool, ListEditorModel) -> Void)? = nil) {
		self._model = State(initialValue: model)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter a name", text: $model.name)
						.focused($inFocus)
						.onAppear {
							inFocus = true
						}
				} header: {
					EmptyView()
				} footer: {
					switch validationResult {
					case .success:
						EmptyView()
					case .failure(let error):
						Text(error.errorDescription ?? "")
					}
				}
				IconPicker(selectedIcon: $model.icon)
			}
			.formStyle(.grouped)
			.navigationTitle("Edit List")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion?(true, model)
					}
					.disabled(!validationResult.isSuccess)
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
