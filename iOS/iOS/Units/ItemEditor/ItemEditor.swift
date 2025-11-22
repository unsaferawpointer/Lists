//
//  ItemEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 23.10.2025.
//

import SwiftUI

struct ItemEditor: View {

	@State var properties: Item.Properties

	var completion: ((Bool, Item.Properties) -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var validationResult: ListValidator.ValidationResult {
		validator.validate(name: properties.title)
	}

	// MARK: - Initialization

	init(properties: Item.Properties, completion: ((Bool, Item.Properties) -> Void)? = nil) {
		self._properties = State(initialValue: properties)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter a name", text: $properties.title)
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
						completion?(true, properties)
					}
					.disabled(!validationResult.isSuccess)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						completion?(false, properties)
					}
				}
			}
		}
	}
}

#Preview {
	ItemEditor(properties: .init(title: "Default Item", isStrikethrough: false, list: nil))
}
