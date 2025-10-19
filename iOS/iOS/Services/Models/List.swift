//
//  List.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct List: Sendable {

	let uuid: UUID
	var name: String

	// MARK: - Initialization

	init(uuid: UUID, name: String) {
		self.uuid = uuid
		self.name = name
	}
}

// MARK: - Identifiable
extension List: Identifiable {

	var id: UUID {
		uuid
	}
}
