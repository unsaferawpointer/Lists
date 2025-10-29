//
//  List.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct List: Sendable {

	let uuid: UUID
	var properties: Properties

	// MARK: - Initialization

	init(uuid: UUID, properties: Properties) {
		self.uuid = uuid
		self.properties = properties
	}
}

// MARK: - Identifiable
extension List: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - Computed Properties
extension List {

	var name: String {
		properties.name
	}
}

// MARK: - Nested Data Structs
extension List {

	struct Properties {
		var name: String
		var icon: Icon?
	}
}
