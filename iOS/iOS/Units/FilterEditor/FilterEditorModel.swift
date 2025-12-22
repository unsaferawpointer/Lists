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

	let id: UUID

	var properties: Filter.Properties = .init(name: "")

	var relationships: Filter.Relationships = .init()

	var isLoading = false

	// MARK: - UI

	var tags: [Tag] = []

	// MARK: - Services

	@ObservationIgnored
	let providers: Providers

	@ObservationIgnored
	let dataManager: any DataManager

	// MARK: - Initialization

	init(id: UUID, dataManager: any DataManager, providers: Providers) {
		self.id = id
		self.dataManager = dataManager
		self.providers = providers
		Task {
			let request = TagsRequestV2()
			for await _ in providers.tags.stream {
				let tags = try await providers.tags.fetchObjects(with: request)
				self.tags = tags.map {
					Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
				}
			}
		}
	}
}

// MARK: - Public Interface
extension FilterEditorModel {

	func fetchData() async {
		await MainActor.run {
			self.isLoading = true
		}
		let request = FilterRequestV2(identifier: id)
		guard let filters = try? await providers.filter.fetchObjects(with: request), let first = filters.first else {
			return
		}
		let tagsRequest = TagsRequestV2()
		guard let tags = try? await providers.tags.fetchObjects(with: tagsRequest) else {
			return
		}
		await MainActor.run {
			self.properties = first.properties
			self.relationships = first.relationships ?? .init()

			self.tags = tags.map {
				Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
			}

			self.isLoading = false
		}
	}

	func save() async {
		let request = FilterRequestV2(identifier: id)
		await MainActor.run {
			self.isLoading = true
		}
		try? await dataManager.updateObjects(request: request, properties: properties, relationships: relationships)
	}
}

// MARK: - Nested Data Structs
extension FilterEditorModel {

	struct Providers {
		let filter: any DataProviderProtocol<FilterEntity>
		let tags: any DataProviderProtocol<TagEntity>
	}
}
