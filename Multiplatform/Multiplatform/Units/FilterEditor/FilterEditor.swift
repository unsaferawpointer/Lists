//
//  FilterEditor.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 02.01.2026.
//

import SwiftUI
import SwiftData

struct FilterEditor {

	@Environment(\.dismiss) var dismiss

	@Environment(\.modelContext) private var modelContext

	@Query private var tags: [Tag]

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
				Section {
					LabeledContent("Name") {
						TextField("Required", text: $model.name)
					}
					NavigationLink {
						IconPicker(icon: $model.icon)
					} label: {
						LabeledContent("icon") {
							Image(systemName: model.icon.systemName)
						}
					}
				}
				Section("Tags") {
					Picker(selection: $model.matchType) {
						ForEach(MatchType.allCases) { type in
							Text(type.name)
								.tag(type)
						}
					} label: {
						Text("Match type")
					}
					NavigationLink {
						List {
							ForEach(tags) { tag in
								Button {
									if model.tags.contains(tag.id) {
										model.tags.remove(tag.id)
									} else {
										model.tags.insert(tag.id)
									}
								} label: {
									HStack {
										Label(tag.title, systemImage: "tag")
										Spacer()
										if model.tags.contains(tag.id) {
											Image(systemName: "checkmark")
										}
									}
									.listItemTint(.primary)
								}
							}
						}
					} label: {
						HStack {
							Text("Selected")
								.lineLimit(1)
							Spacer()
							Text(model.tags.isEmpty ? "Not Selected" : tags.filter { model.tags.contains($0.id) }.map(\.title).joined(separator: " | "))
								.foregroundStyle(.secondary)
								.lineLimit(1)
						}
					}
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
	FilterEditor(title: "Edit Filter", model: .init(name: "Default Filter", icon: .receipt, matchType: .any, tags: [])) { newModel in

	}
}
