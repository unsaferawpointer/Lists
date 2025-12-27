//
//  FilterEditor.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import SwiftUI

struct FilterEditor: View {

	@Bindable var model: FilterEditorModel

	var completion: (() -> Void)?

	@FocusState var inFocus: Bool

	let validator = ListValidator()

	var validationResult: ListValidator.ValidationResult {
		return validator.validate(name: model.properties.name)
	}

	// MARK: - Initialization

	init(model: FilterEditorModel, completion: (() -> Void)? = nil) {
		self.model = model
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			Group {
				if !model.isLoading {
					Form {
						Section {
							LabeledContent("Name") {
								TextField("Required", text: $model.properties.name)
									.focused($inFocus)
									.onAppear {
										inFocus = true
									}
							}
							NavigationLink {
								IconPicker(selectedIcon: $model.properties.icon)
							} label: {
								LabeledContent("Icon") {
									Image(systemName: model.properties.icon?.iconName ?? "tag")
								}
							}
						} footer: {
							switch validationResult {
							case .success:
								EmptyView()
							case .failure(let error):
								Text(error.errorDescription ?? "")
							}
						}
						Section {
							LabeledContent("Strikethrough:") {
								Picker("", selection: .init(get: {
									model.properties.itemOptions?.isStrikethrough
								}, set: { newValue in
									guard let newValue else {
										model.properties.itemOptions = nil
										return
									}
									if newValue {
										model.properties.itemOptions = [.strikethrough]
									} else {
										model.properties.itemOptions = []
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
								.labelsHidden()
							}
						}
						Section {
							Picker(selection: .init(get: {
								model.relationships.tagsMatchType ?? .any
							}, set: { newValue in
								model.relationships.tagsMatchType = newValue
							})) {
								Text("Any")
									.tag(Optional<TagsFilter.MatchType>.some(.any))
								Text("All")
									.tag(Optional<TagsFilter.MatchType>.some(.all))
								Text("Not")
									.tag(Optional<TagsFilter.MatchType>.some(.not))
							} label: {
								Text("Match Type")
							}

							NavigationLink {
								tagsPicker()
							} label: {
								HStack {
									Text("Tags:")
										.lineLimit(1)
									Spacer()
									Text(model.tagsDescription)
										.foregroundStyle(.secondary)
										.lineLimit(1)
								}
							}
						}
					}
					.formStyle(.grouped)
				} else {
					ProgressView()
						.progressViewStyle(.circular)
				}
			}
			.navigationTitle("Edit Filter")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				buildToolbar()
			}
		}
		.task {
			await model.fetchData()
		}
	}
}

// MARK: - Helpers
private extension FilterEditor {

	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button(role: .confirm) {
				Task {
					await model.save()
					await MainActor.run {
						completion?()
					}
				}
			}
			.disabled(!validationResult.isSuccess || model.isLoading)
		}
		ToolbarItem(placement: .cancellationAction) {
			Button(role: .close) {
				completion?()
			}
		}
	}

	@ViewBuilder
	func buildIconPicker() -> some View {

	}

	@ViewBuilder
	func tagsPicker() -> some View {
		if !model.tags.isEmpty {
			Form {
				ForEach(model.tags) { tag in
					HStack {
						Label(tag.name, systemImage: "tag")
						Spacer()
						if model.relationships.tags?.contains(tag.id) == true {
							Image(systemName: "checkmark")
								.foregroundColor(.primary)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						if model.relationships.tags?.contains(tag.id) == true {
							model.relationships.tags?.remove(tag.id)
						} else {
							model.relationships.tags?.insert(tag.id)
						}
					}
				}
			}
		} else {
			ContentUnavailableView("No Tags", systemImage: "tag", description: Text("Add tag"))
		}
	}
}

//#Preview {
//	FilterEditor(model: .init(selected: <#T##Set<UUID>#>, provider: <#T##ModelsProvider<Tag>#>))
//}
