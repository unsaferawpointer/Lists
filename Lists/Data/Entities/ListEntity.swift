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

	var offset: Int

	var name: String

	var appearence: ListAppearence?

	var isHidden: Bool

	@Relationship(deleteRule: .cascade, inverse: \ItemEntity.list)
	var items: [ItemEntity]

	// MARK: - Initialization

	init(
		timestamp: Date,
		offset: Int = 0,
		name: String,
		isHidden: Bool = false,
		appearence: ListAppearence?,
		items: [ItemEntity] = []
	) {
		self.timestamp = timestamp
		self.offset = offset
		self.name = name
		self.appearence = appearence
		self.isHidden = isHidden
		self.items = items
	}
}
