//
//  Item.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct Item: Sendable {

	let uuid: UUID

	let properties: Properties

	let tags: [Tag]

	// MARK: - Initialization

	init(uuid: UUID, properties: Properties, tags: [Tag]) {
		self.uuid = uuid
		self.properties = properties
		self.tags = tags
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - ModelConvertable
extension Item: ModelConvertable {

	typealias Entity = ItemEntity
}

// MARK: - Computed Properties
extension Item {

	var title: String { properties.title }

	var isStrikethrough: Bool { properties.isStrikethrough }
}

// MARK: - Nested Data Structs
extension Item {

	struct Properties: Sendable {
		var title: String
		var isStrikethrough: Bool
		var list: UUID?
	}

	struct Relationships {
		var tags: [Object<Tag.Properties, Tag.Relationships>]
	}
}
