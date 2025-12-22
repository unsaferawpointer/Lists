//
//  Object.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.12.2025.
//

import Foundation

struct Object<Properties, Relationships>: Identifiable {

	let id: UUID

	let properties: Properties

	let relationships: Relationships?

	// MARK: - Initialization

	init(id: ID, properties: Properties, relationships: Relationships?) {
		self.id = id
		self.properties = properties
		self.relationships = relationships
	}
}
