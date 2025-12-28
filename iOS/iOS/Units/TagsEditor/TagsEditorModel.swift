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
	let provider: DataProvider

	@ObservationIgnored
	private let storage: any StorageProtocol

	init(selected: Set<UUID>, provider: DataProvider, storage: any StorageProtocol) {
		self.selected = selected
		self.provider = provider
		self.storage = storage
		Task { [weak self] in
			for await _ in provider.stream {
				await self?.fetchTags()
			}
		}
	}
}

extension TagsEditorModel {

	@MainActor
	func fetchTags() async {
		let request = TagsRequest()
		guard let tags = try? await provider.fetchObjects(with: request) else {
			return
		}
		self.tags = tags.map {
			Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
		}
	}
}

// MARK: - Public Interface
extension TagsEditorModel {

	func newTag(with properties: Tag.Properties) {
		let newTag = Tag(uuid: .init(), properties: properties)
		Task {
			try? await storage.addTag(newTag)
		}
	}

	func updateTag(with id: UUID, properties: Tag.Properties) {
		Task {
			try? await storage.updateTag(with: id, properties: properties)
		}
	}

	func deleteTags(with ids: [UUID]) {
		Task {
			try? await storage.deleteTags(with: ids)
		}
	}
}
