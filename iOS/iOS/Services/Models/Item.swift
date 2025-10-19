//
//  Item.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

struct Item {

	var uuid: UUID
	var title: String

	// MARK: - Initialization

	init(uuid: UUID, title: String) {
		self.uuid = uuid
		self.title = title
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	var id: UUID {
		uuid
	}
}
