//
//  DocumentRowModel.swift
//  Lists
//
//  Created by Anton Cherkasov on 29.09.2025.
//

import Foundation

struct DocumentRowModel {

	let uuid: UUID

	let title: String

	let iconName: String

	// MARK: - Initialization

	init(uuid: UUID = UUID(), title: String, iconName: String) {
		self.uuid = uuid
		self.title = title
		self.iconName = iconName
	}
}

// MARK: - Identifiable
extension DocumentRowModel: Identifiable {

	var id: UUID { uuid }
}
