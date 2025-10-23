//
//  ItemEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 23.10.2025.
//

import SwiftUI

struct ItemEditor: View {

	@State var title: String = ""

	var completion: ((Bool, ItemEditorModel) -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var validationResult: ListValidator.ValidationResult {
		validator.validate(name: title)
	}

	// MARK: - Initialization

	init(model: ItemEditorModel, completion: ((Bool, ItemEditorModel) -> Void)? = nil) {
		self._title = State(initialValue: model.title)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter a name", text: $title)
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

			}
			.formStyle(.grouped)
			.navigationTitle("Edit List")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion?(true, .init(title: title))
					}
					.disabled(!validationResult.isSuccess)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						completion?(false, .init(title: ""))
					}
				}
			}
		}
	}
}

#Preview {
	ItemEditor(model: .init(title: "Default Item"))
}
