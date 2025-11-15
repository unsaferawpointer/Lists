//
//  TagEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import SwiftUI

struct TagEditor: View {

	@State var model: TagEditorModel

	var completion: ((Bool, TagEditorModel) -> Void)?

	@FocusState var inFocus: Bool

	let validator = TagValidator()

	var validationResult: TagValidator.ValidationResult {
		validator.validate(name: model.name)
	}

	// MARK: - Initialization

	init(model: TagEditorModel, completion: ((Bool, TagEditorModel) -> Void)? = nil) {
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
			.navigationTitle("Edit Tag")
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
	TagEditor(model: .init(name: "Default Tag"))
}
