//
//  Tag.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.11.2025.
//

import Foundation

struct Tag: Sendable {

	let uuid: UUID
	var properties: Properties

	// MARK: - Initialization

	init(uuid: UUID, properties: Properties) {
		self.uuid = uuid
		self.properties = properties
	}
}

// MARK: - Identifiable
extension Tag: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - ModelConvertable
extension Tag: ModelConvertable {

	typealias Entity = TagEntity
}

// MARK: - Computed Properties
extension Tag {

	var name: String {
		properties.name
	}
}

// MARK: - Nested Data Structs
extension Tag {

	struct Properties {
		var name: String
		var icon: Icon?
	}

	struct Relationships {
		
	}
}
