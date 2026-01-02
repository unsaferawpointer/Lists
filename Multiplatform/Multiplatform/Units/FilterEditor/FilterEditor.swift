//
//  FilterEditor.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 02.01.2026.
//

import SwiftUI

struct FilterEditor {

	@Environment(\.dismiss) var dismiss

	let title: String

	@State var model: Model

	var completion: ((Model) -> Void)?

	// MARK: - Initialization

	init(title: String, model: Model, completion: ((Model) -> Void)?) {
		self._model = State(initialValue: model)
		self.title = title
		self.completion = completion
	}
}

// MARK: - View
extension FilterEditor: View {

	var body: some View {
		NavigationStack {
			Form {
				LabeledContent("Name") {
					TextField("Required", text: $model.name)
				}
			}
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion?(model)
						dismiss()
					}
				}
			}
		}
	}
}

#Preview {
	FilterEditor(title: "Edit Filter", model: .init(name: "Default Filter")) { newModel in

	}
}
