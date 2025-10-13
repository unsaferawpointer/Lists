//
//  ListEditor.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftData
import SwiftUI

struct ListEditor {

	// MARK: - Enviroment

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	// MARK: - DI

	var offset: Int

	var list: ListEntity?

	// MARK: - Internal State

	@State private var name: String = ""

	@State private var icon: Icon = .document

	@FocusState private var isFocused: Bool

	// MARK: - Initialization

	init(list: ListEntity?, with offset: Int) {
		self.list = list
		self.offset = offset
		self._icon = State(initialValue: list?.appearence?.icon ?? .folder)
		self._name = State(initialValue: list?.name ?? "")
	}
}

// MARK: - View
extension ListEditor: View {

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Name", text: $name)
						.focused($isFocused)
						.submitLabel(.done)
						.onSubmit {
							save()
							dismiss()
						}
						.onAppear {
							self.isFocused = true
						}
				} footer: {
					if !isValid() {
						Text("Textfield is Empty")
							.foregroundStyle(.red)
							.font(.callout)
					}
				}
				Section("Icon") {
					IconPicker(selectedIcon: $icon)
				}
			}
			.formStyle(.grouped)
			.scrollDismissesKeyboard(.immediately)
			.toolbar {
				buildToolbar()
			}
		}
	}
}

// MARK: - Helpers
private extension ListEditor {

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
private extension ListEditor {

	func save() {
		withAnimation {
			guard let list else {
				let newList = ListEntity(timestamp: .now, name: name, appearence: .init(icon: icon))
				newList.offset = offset
				modelContext.insert(newList)
				return
			}
			list.offset = offset
			list.name = name
			list.appearence = ListAppearence(icon: icon)
			try? modelContext.save()
		}
	}

	func isValid() -> Bool {
		return !name
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.isEmpty
	}
}

#Preview {
	ListEditor(
		list: .init(
			timestamp: .now,
			name: "New List",
			appearence: .init(icon: .document)
		),
		with: 0
	)
}
