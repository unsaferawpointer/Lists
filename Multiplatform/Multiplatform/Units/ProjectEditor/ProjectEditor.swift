//
//  ProjectEditor.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 30.12.2025.
//

import SwiftUI

struct ProjectEditor {

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
extension ProjectEditor: View {

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
	ProjectEditor(title: "Edit Project", model: .init(name: "Default Project")) { newModel in

	}
}
