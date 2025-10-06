//
//  ItemEditor.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftData
import SwiftUI

struct ItemEditor: View {

	// MARK: - Enviroment

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	// MARK: - Entities

	var item: ItemEntity?

	var list: ListEntity?

	// MARK: - Local State

	@State private var title: String = ""

	@FocusState private var isTitleFocused: Bool

	// MARK: - Initialization

	init(item: ItemEntity?, list: ListEntity? = nil) {
		self.item = item
		self.list = list
		self._title = State(initialValue: item?.title ?? "")
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Item Title", text: $title)
						.focused($isTitleFocused)
						.submitLabel(.done)
						.onSubmit {
							save()
							dismiss()
						}
						.onAppear {
							isTitleFocused = true
						}
				} footer: {
					if !isValid() {
						Text("Textfield is Empty")
							.foregroundStyle(.red)
							.font(.callout)
					}
				}
			}
			.formStyle(.grouped)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						save()
						dismiss()
					}
					.disabled(!isValid())
				}
			}
		}
	}
}

// MARK: - Helpers
private extension ItemEditor {

	func save() {
		withAnimation {
			guard let item else {
				let newItem = ItemEntity(timestamp: .now, title: title, list: list)
				modelContext.insert(newItem)
				return
			}
			item.title = title
			try? modelContext.save()
		}
	}

	func isValid() -> Bool {
		return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}

#Preview {
	ItemEditor(item: .init(timestamp: .now, title: "Title", list: nil))
}
