//
//  DocumentItem.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation

struct DocumentItem {

	let uuid: UUID = UUID()

	var name: String
	var iconName: String
}

// MARK: - Identifiable
extension DocumentItem: Identifiable {

	var id: UUID {
		uuid
	}
}
