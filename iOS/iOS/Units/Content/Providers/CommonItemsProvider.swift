//
//  CommonItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation

final class CommonItemsProvider {

	let request: ItemsRequest

	let dataProvider: DataProvider

	// MARK: - Initialization

	init(request: ItemsRequest, dataProvider: DataProvider) {
		self.request = request
		self.dataProvider = dataProvider
	}
}

// MARK: - ItemsProvider
extension CommonItemsProvider: ItemsProvider {

	@MainActor
	func fetchItems() async throws -> [Object<Item.Properties, Item.Relationships>] {
		let request = ItemsRequest()
		let items = try await dataProvider.fetchObjects(with: request)
		return items
	}

	var stream: NotificationCenter.Notifications {
		return dataProvider.stream
	}
}
