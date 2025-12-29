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

	var name: String

	// MARK: - Options

	var isArchived: Bool

	var icon: Icon

	// MARK: - Relationships

	@Relationship(deleteRule: .cascade)
	var items: [Item] = []

	// MARK: - Additional Info

	var creationDate: Date

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		name: String = "",
		isArchived: Bool = false,
		icon: Icon = .none,
		creationDate: Date = .now
	) {
		self.uuid = uuid
		self.name = name
		self.isArchived = isArchived
		self.icon = icon
		self.creationDate = creationDate
	}
}
