//
//  ItemEditor.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftData
import SwiftUI

struct ItemEditor {

	// MARK: - Enviroment

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	// MARK: - Entities

	var item: ItemEntity?

	var list: ListEntity?

	// MARK: - Local State

	@State private var title: String = ""

	@State private var subtitle: String = ""

	@FocusState private var focusedField: Field?

	enum Field {
		case title
		case subtitle
	}

	// MARK: - Initialization

	init(item: ItemEntity?, list: ListEntity? = nil) {
		self.item = item
		self.list = list
		self._title = State(initialValue: item?.title ?? "")
		self._subtitle = State(initialValue: item?.subtitle ?? "")
	}
}

// MARK: - View
extension ItemEditor: View {

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Title", text: $title)
						.focused($focusedField, equals: .title)
						.submitLabel(.next)
						.onSubmit {
							focusedField = .subtitle
						}
						.onAppear {
							focusedField = .title
						}
					TextField("Note", text: $subtitle)
						.focused($focusedField, equals: .subtitle)
						.submitLabel(.done)
						.onSubmit {
							save()
							dismiss()
						}
				} header: {
					EmptyView()
				} footer: {
					if !isValid() {
						Text("Textfield is Empty")
							.foregroundStyle(.red)
							.font(.callout)
					}
				}
			}
			.formStyle(.grouped)
			.navigationTitle(item == nil ? "New Item" : "Edit Item")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				buildToolbar()
			}
		}
	}
}

// MARK: - Helpers
private extension ItemEditor {

	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
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

// MARK: - Helpers
private extension ItemEditor {

	func save() {
		withAnimation {
			guard let item else {
				let newItem = ItemEntity(
					timestamp: .now,
					title: title,
					subtitle: subtitle.isEmpty ? nil : subtitle,
					list: list
				)
				modelContext.insert(newItem)
				return
			}
			item.title = title
			item.subtitle = subtitle.isEmpty ? nil : subtitle
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
