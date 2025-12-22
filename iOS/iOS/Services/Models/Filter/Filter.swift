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
	let tags: Set<UUID>?

	// MARK: - Initialization

	init(uuid: UUID, properties: Properties, tags: Set<UUID>?) {
		self.uuid = uuid
		self.properties = properties
		self.tags = tags
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
		var itemOptions: ItemOptions?
	}

	struct Relationships {
		var tags: Set<UUID>?
	}
}
