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

	// MARK: - Relationships

	@Relationship(deleteRule: .nullify, inverse: \Tag.items)
	var tags: [Tag] = []

	@Relationship(deleteRule: .nullify, inverse: \Project.items)
	var project: Project?

	// MARK: - Additional Info

	var creationDate: Date

	// MARK: - Order

	var index: Int

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		text: String = "",
		isCompleted: Bool = false,
		isArchived: Bool = false,
		creationDate: Date = .now,
		index: Int = 0
	) {
		self.uuid = uuid
		self.text = text
		self.isCompleted = isCompleted
		self.isArchived = isArchived
		self.creationDate = creationDate
		self.index = index
	}
}
