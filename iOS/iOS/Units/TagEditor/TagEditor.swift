//
//  TagEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 10.12.2025.
//

import SwiftUI

struct TagEditor: View {

	@Environment(\.dismiss) private var dismiss

	@State var properties: Tag.Properties

	var completion: ((Bool, Tag.Properties) -> Void)?

	@FocusState var inFocus: Bool

	let validator = TagValidator()

	var validationResult: TagValidator.ValidationResult {
		validator.validate(name: properties.name)
	}

	// MARK: - Initialization

	init(properties: Tag.Properties, completion: ((Bool, Tag.Properties) -> Void)? = nil) {
		self._properties = State(initialValue: properties)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter a name", text: $properties.name)
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
			.navigationTitle("Edit Tag")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						dismiss()
						completion?(true, properties)
					}
					.disabled(!validationResult.isSuccess)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						dismiss()
						completion?(false, properties)
					}
				}
			}
		}
	}
}

#Preview {
	TagEditor(properties: .init(name: "Default Tag"))
}
