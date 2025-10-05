//
//  ListEntity.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import Foundation
import SwiftData

@Model
final class ListEntity {

	var timestamp: Date

	var name: String

	var icon: Icon?

	@Relationship(deleteRule: .cascade, inverse: \ItemEntity.list)
	var items: [ItemEntity]

	// MARK: - Initialization

	init(timestamp: Date, name: String, icon: Icon, items: [ItemEntity] = []) {
		self.timestamp = timestamp
		self.name = name
		self.icon = icon
		self.items = items
	}
}
