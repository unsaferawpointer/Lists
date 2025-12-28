//
//  ItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation

protocol ItemsProvider {
	func fetchItems() async throws -> [Object<Item.Properties, Item.Relationships>]
	var stream: NotificationCenter.Notifications { get }
}
