//
//  Tag.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import Foundation
import SwiftData

@Model
final class Tag {

	var uuid: UUID

	var title: String

	// MARK: - Options

	var isArchived: Bool

	// MARK: - Relationships

	@Relationship(deleteRule: .nullify)
	var items: [Item] = []

	@Relationship(deleteRule: .nullify, inverse: \Filter.tags)
	var filters: [Filter] = []

	// MARK: - Additional Info

	var creationDate: Date

	var index: Int

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		title: String = "",
		isArchived: Bool = false,
		creationDate: Date = .now,
		index: Int = 0
	) {
		self.uuid = uuid
		self.title = title
		self.isArchived = isArchived
		self.creationDate = creationDate
		self.index = index
	}
}
