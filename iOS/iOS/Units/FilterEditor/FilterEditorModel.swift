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

	var tags: [Tag] = []

	@ObservationIgnored
	let tagsProvider: ModelsProvider<Tag>

	init(properties: Filter.Properties, tagsProvider: ModelsProvider<Tag>) {
		self.properties = properties
		self.tagsProvider = tagsProvider
		Task { @MainActor in
			for await change in await tagsProvider.stream() {
				self.tags = change
			}
		}
	}
}
