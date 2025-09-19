//
//  DocumentDetailsView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI

struct DocumentDetailsView: View {

	@Environment(\.dismiss) private var dismiss

	@State var document: DocumentItem = .init(name: "Today", iconName: "doc.text")

	var body: some View {
		NavigationStack {
			Form {
				TextField("Document name", text: $document.name)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark")
					}

				}
				ToolbarItem(placement: .confirmationAction) {
					Button {
						dismiss()
					} label: {
						Label("Save", systemImage: "checkmark")
					}

				}
			}
		}
	}
}

// MARK: - Nested data structs
extension DocumentDetailsView {

}

#Preview {
	DocumentDetailsView()
}
