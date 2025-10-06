//
//  ListEditor.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftData
import SwiftUI

struct ListEditor: View {

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	var list: ListEntity?

	@State var name: String = ""

	@State var icon: Icon = .document

	init(list: ListEntity?) {
		self.list = list
		self._icon = State(initialValue: list?.icon ?? .folder)
		self._name = State(initialValue: list?.name ?? "")
	}

	var body: some View {
		NavigationStack {
			Form {
				TextField("Name", text: $name)
				Section("Icon") {
					IconPicker(selectedIcon: $icon)
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
				}
			}
		}
	}
}

// MARK: - Helpers
private extension ListEditor {

	func save() {
		withAnimation {
			guard let list else {
				let newList = ListEntity(timestamp: .now, name: "New List", icon: icon)
				modelContext.insert(newList)
				return
			}
			list.name = name
			list.icon = icon
			try? modelContext.save()
		}
	}
}

#Preview {
	ListEditor(list: .init(timestamp: .now, name: "New List", icon: .document))
}
