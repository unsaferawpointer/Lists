//
//  FilterEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import SwiftUI

struct FilterEditor: View {

	@Bindable var model: FilterEditorModel

	var completion: ((Bool, Filter.Properties, Set<UUID>) -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var validationResult: ListValidator.ValidationResult {
		validator.validate(name: model.properties.name)
	}

	// MARK: - Initialization

	init(model: FilterEditorModel, completion: ((Bool, Filter.Properties, Set<UUID>) -> Void)? = nil) {
		self.model = model
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Enter a name", text: $model.properties.name)
						.focused($inFocus)
						.onAppear {
							inFocus = true
						}
				} header: {
					Text("Title")
				} footer: {
					switch validationResult {
					case .success:
						EmptyView()
					case .failure(let error):
						Text(error.errorDescription ?? "")
					}
				}
				Section("Icons") {
					IconPicker(selectedIcon: $model.properties.icon)
				}

				Section {
					Picker("Strikethrough", selection: .init(get: {
						model.properties.itemOptions?.isStrikethrough
					}, set: { newValue in
						guard let newValue else {
							model.properties.itemOptions = nil
							return
						}
						if newValue {
							model.properties.itemOptions?.insert(.strikethrough)
						} else {
							model.properties.itemOptions?.remove(.strikethrough)
						}
					})) {
						Text("Any")
							.tag(Optional<Bool>.none)
						Divider()
						Text("Strikethrough")
							.tag(true)
						Text("Not Strikethrough")
							.tag(false)
					}
				}
				Section("Tags") {
					tagsPicker()
				}
			}
			.formStyle(.grouped)
			.navigationTitle("Edit Filter")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion?(true, model.properties, model.selectedTags)
					}
					.disabled(!validationResult.isSuccess)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						completion?(false, .init(name: ""), model.selectedTags)
					}
				}
			}
		}
		.task {
			try? await model.tagsProvider.fetchData()
		}
	}
}

// MARK: - Helpers
private extension FilterEditor {

	@ViewBuilder
	func tagsPicker() -> some View {
		ForEach(model.tags) { tag in
			HStack {
				Label(tag.name, systemImage: "tag")
				Spacer()
				if model.selectedTags.contains(tag.id) {
					Image(systemName: "checkmark")
						.foregroundColor(.primary)
				}
			}
			.contentShape(Rectangle())
			.onTapGesture {
				if model.selectedTags.contains(tag.id) {
					model.selectedTags.remove(tag.id)
				} else {
					model.selectedTags.insert(tag.id)
				}
			}
		}
	}
}

//#Preview {
//	FilterEditor(model: .init(selected: <#T##Set<UUID>#>, provider: <#T##ModelsProvider<Tag>#>))
//}
