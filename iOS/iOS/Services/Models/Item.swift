//
//  Item.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct Item: Sendable {

	var uuid: UUID
	var title: String
	var isStrikethrough: Bool

	// MARK: - Initialization

	init(uuid: UUID, title: String, isStrikethrough: Bool) {
		self.uuid = uuid
		self.title = title
		self.isStrikethrough = isStrikethrough
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	var id: UUID {
		uuid
	}
}
