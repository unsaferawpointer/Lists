//
//  ItemDetailsView.swift
//  Lists
//
//  Created by Anton Cherkasov on 19.09.2025.
//

import SwiftUI

struct ItemDetailsView: View {

	@Environment(\.dismiss) private var dismiss

	@State var item: ListItem = .init(text: "")

	var body: some View {
		NavigationStack {
			Form {
				TextField("Document name", text: $item.text)
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

#Preview {
	ItemDetailsView()
}
