//
//  FilterEditorModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation

@Observable
final class FilterEditorModel {

	var properties: Filter.Properties

	var selectedTags: Set<UUID> = []

	var tags: [Tag] = []

	@ObservationIgnored
	let tagsProvider: ModelsProvider<Tag>

	// MARK: - Initialization

	init(properties: Filter.Properties, selectedTags: Set<UUID>, tagsProvider: ModelsProvider<Tag>) {
		self.properties = properties
		self.selectedTags = selectedTags
		self.tagsProvider = tagsProvider
		Task { @MainActor in
			for await change in await tagsProvider.stream() {
				self.tags = change
			}
		}
	}
}
