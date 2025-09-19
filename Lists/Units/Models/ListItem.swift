//
//  ListItem.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation

struct ListItem {

	let uuid: UUID = UUID()

	var text: String

	var subitems: [ListItem]?
}

// MARK: - Identifiable
extension ListItem: Identifiable {

	var id: UUID {
		uuid
	}
}
