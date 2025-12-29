//
//  Project.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 29.12.2025.
//

import Foundation
import SwiftData

@Model
final class Project {

	var uuid: UUID

	var text: String

	// MARK: - Options

	var isArchived: Bool

	// MARK: - Relationships

	@Relationship(deleteRule: .cascade)
	var items: [Item] = []

	// MARK: - Additional Info

	var creationDate: Date

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		text: String = "",
		isArchived: Bool = false,
		creationDate: Date = .now
	) {
		self.uuid = uuid
		self.text = text
		self.isArchived = isArchived
		self.creationDate = creationDate
	}
}
