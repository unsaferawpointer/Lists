//
//  FilteredItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation

final class FilteredItemsProvider {

	let id: UUID

	let dataProvider: DataProvider

	// MARK: - Initialization

	init(id: UUID, dataProvider: DataProvider) {
		self.id = id
		self.dataProvider = dataProvider
	}
}

// MARK: - ItemsProvider
extension FilteredItemsProvider: ItemsProvider {

	@MainActor
	func fetchItems() async throws -> [Object<Item.Properties, Item.Relationships>] {
		let filter = try await fetchFilter()

		let request = ItemsRequest(
			tagsFilter: filter.relationships?.tagsFilter,
			itemOptions: filter.properties.itemOptions
		)
		let items = try await dataProvider.fetchObjects(with: request)
		return items
	}

	var stream: NotificationCenter.Notifications {
		return dataProvider.stream
	}
}

private extension FilteredItemsProvider {

	func fetchFilter() async throws -> Object<Filter.Properties, Filter.Relationships> {
		let request = FilterRequest(identifier: id)
		let filters = try await dataProvider.fetchObjects(with: request)
		guard let filter = filters.first else {
			fatalError("No filter with id: \(id)")
		}
		return filter
	}
}
