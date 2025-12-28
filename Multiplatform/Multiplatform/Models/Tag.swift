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

	var creationDate: Date

	// MARK: - Relationships

	@Relationship(deleteRule: .nullify)
	var items: [Item] = []

	// MARK: - Initialization

	init(
		uuid: UUID,
		title: String = "",
		isArchived: Bool = false,
		creationDate: Date = .now
	) {
		self.uuid = uuid
		self.title = title
		self.isArchived = isArchived
		self.creationDate = creationDate
	}
}
