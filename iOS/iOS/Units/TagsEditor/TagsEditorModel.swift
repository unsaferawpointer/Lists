//
//  TagsEditorModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import Foundation

@Observable
final class TagsEditorModel {

	var selected: Set<UUID>

	var tags: [Tag] = []

	@ObservationIgnored
	let provider: ModelsProvider<Tag>

	@ObservationIgnored
	private let storage: any StorageProtocol

	init(selected: Set<UUID>, provider: ModelsProvider<Tag>, storage: any StorageProtocol) {
		self.selected = selected
		self.provider = provider
		self.storage = storage
		Task { @MainActor in
			for await change in await provider.stream() {
				self.tags = change
			}
		}
	}
}

// MARK: - Public Interface
extension TagsEditorModel {

	func newTag() {
		let newTag = Tag(uuid: .init(), properties: .init(name: "New Tag"))
		Task {
			try? await storage.addTag(newTag)
		}
	}
}
