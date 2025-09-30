//
//  DocumentEntity.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation
import SwiftData

@Model
final class DocumentEntity {

	var uuid: UUID

	var name: String?

	@Relationship(deleteRule: .cascade)
	var items: [ItemEntity]

	// MARK: - Initialization

	init(uuid: UUID = UUID(), name: String? = nil, items: [ItemEntity] = []) {
		self.uuid = uuid
		self.name = name
		self.items = items
	}
}
