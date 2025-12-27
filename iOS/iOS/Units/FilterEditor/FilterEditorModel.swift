//
//  FilterEditorModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation

@Observable
final class FilterEditorModel {

	// MARK: - Basic Data

	let id: UUID?

	var properties: Filter.Properties = .init(name: "")

	var relationships: Filter.Relationships = .init(tagsMatchType: .any)

	var isLoading = false

	// MARK: - UI

	var tags: [Tag] = []

	// MARK: - Services

	@ObservationIgnored
	let provider: DataProvider

	@ObservationIgnored
	let dataManager: any DataManager

	// MARK: - Initialization

	init(id: UUID?, dataManager: any DataManager, provider: DataProvider) {
		self.id = id
		self.dataManager = dataManager
		self.provider = provider
		Task {
			let request = TagsRequestV2()
			for await _ in provider.stream {
				let tags = try await provider.fetchObjects(with: request)
				self.tags = tags.map {
					Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
				}
			}
		}
	}
}

// MARK: - Computed Properties
extension FilterEditorModel {

	var tagsDescription: String {
		guard relationships.tags?.isEmpty == false else {
			return "Not Selected"
		}
		return tags.filter { tag in
			relationships.tags?.contains(tag.id) == true
		}.map {
			$0.name
		}.joined(separator: ", ")
	}

	var tagsFilterDescription: String {
		guard relationships.tags?.isEmpty == false else {
			return "No tags selected"
		}
		return relationships.tagsMatchType.description
	}
}

// MARK: - Public Interface
extension FilterEditorModel {

	@MainActor
	func fetchData() async {
		self.isLoading = true

		let tagsRequest = TagsRequestV2()
		guard let tags = try? await provider.fetchObjects(with: tagsRequest) else {
			return
		}
		self.tags = tags.map {
			Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
		}

		if let id {
			let request = FilterRequestV2(identifier: id)
			guard let filters = try? await provider.fetchObjects(with: request), let first = filters.first else {
				return
			}
			self.properties = first.properties
			self.relationships = first.relationships ?? .init(tagsMatchType: .any)
		}
		self.isLoading = false
	}

	@MainActor
	func save() async {
		self.isLoading = true
		guard let id else {
			try? await dataManager.insertObject(type: FilterEntity.self, properties: properties, relationships: relationships)
			return
		}
		let request = FilterRequestV2(identifier: id)
		try? await dataManager.updateObjects(request: request, properties: properties, relationships: relationships)
	}
}

