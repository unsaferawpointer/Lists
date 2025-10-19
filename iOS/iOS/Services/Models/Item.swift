//
//  Item.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct Item {

	var uuid: UUID
	var item: String

	// MARK: - Initialization

	init(uuid: UUID, item: String) {
		self.uuid = uuid
		self.item = item
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	var id: UUID {
		uuid
	}
}
