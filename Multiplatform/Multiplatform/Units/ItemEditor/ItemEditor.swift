//
//  ItemEditor.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 02.01.2026.
//

import SwiftUI

struct ItemEditor {

	@Environment(\.dismiss) var dismiss

	@State var title: String

	@State var model: Model

	var completion: ((Model) -> Void)?

	// MARK: - Initialization

	init(title: String, model: Model, completion: ((Model) -> Void)?) {
		self._title = State(initialValue: title)
		self._model = State(initialValue: model)
		self.completion = completion
	}
}

// MARK: - View
extension ItemEditor: View {

	var body: some View {
		NavigationStack {
			Form {
				LabeledContent("Name") {
					TextField("Required", text: $model.text)
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
	ItemEditor(title: "New Item", model: .init(text: "Default Item")) { _ in

	}
}
