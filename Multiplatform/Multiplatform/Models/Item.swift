//
//  Item.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation
import SwiftData

@Model
final class Item {

	var uuid: UUID

	var text: String

	// MARK: - Options

	var isCompleted: Bool

	var isArchived: Bool

	var creationDate: Date

	// MARK: - Relationships

	@Relationship(deleteRule: .nullify, inverse: \Tag.items)
	var tags: [Tag] = []

	// MARK: - Initialization

	init(
		uuid: UUID,
		text: String = "",
		isCompleted: Bool = false,
		isArchived: Bool = false,
		creationDate: Date = .now
	) {
		self.uuid = uuid
		self.text = text
		self.isCompleted = isCompleted
		self.isArchived = isArchived
		self.creationDate = creationDate
	}
}
