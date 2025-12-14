//
//  Filter.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation

struct Filter: Sendable {

	let uuid: UUID
	var properties: Properties

	// MARK: - Initialization

	init(uuid: UUID, properties: Properties) {
		self.uuid = uuid
		self.properties = properties
	}
}

// MARK: - Identifiable
extension Filter: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - ModelConvertable
extension Filter: ModelConvertable {

	typealias Entity = FilterEntity
}

// MARK: - Computed Properties
extension Filter {

	var name: String {
		properties.name
	}
}

// MARK: - Nested Data Structs
extension Filter {

	struct Properties {
		var name: String
		var icon: Icon?
		var strikethrough: Bool?
		var tags: Set<UUID>
		var list: UUID?
	}
}
