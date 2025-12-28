//
//  ListItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation

final class ListItemsProvider {

	let id: UUID

	let dataProvider: DataProvider

	// MARK: - Initialization

	init(id: UUID, dataProvider: DataProvider) {
		self.id = id
		self.dataProvider = dataProvider
	}
}

// MARK: - ItemsProvider
extension ListItemsProvider: ItemsProvider {

	@MainActor
	func fetchItems() async throws -> [Object<Item.Properties, Item.Relationships>] {
		let list = try await fetchList()
		let request = ItemsRequest(list: id)
		let items = try await dataProvider.fetchObjects(with: request)
		return items
	}

	var stream: NotificationCenter.Notifications {
		return dataProvider.stream
	}
}

// MARK: - Helpers
private extension ListItemsProvider {

	func fetchList() async throws -> Object<List.Properties, List.Relationships> {
		let request = ListRequest(identifier: id)
		let lists = try await dataProvider.fetchObjects(with: request)
		guard let list = lists.first else {
			fatalError("No filter with id: \(id)")
		}
		return list
	}
}
