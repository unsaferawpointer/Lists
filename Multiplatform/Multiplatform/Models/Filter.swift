//
//  Filter.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 29.12.2025.
//

import Foundation
import SwiftData

@Model
final class Filter {

	var uuid: UUID

	var title: String

	// MARK: - Options

	var isCompleted: Bool = false

	var isAchieved: Bool = false

	// MARK: - Relationships

	@Relationship(deleteRule: .cascade)
	var tags: [Tag] = []

	// MARK: - Additional Info

	var creationDate: Date

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		title: String = "",
		isCompleted: Bool = false,
		isAchieved: Bool = false,
		creationDate: Date = .now
	) {
		self.uuid = uuid
		self.title = title
		self.isCompleted = isCompleted
		self.isAchieved = isAchieved
		self.creationDate = creationDate
	}
}
