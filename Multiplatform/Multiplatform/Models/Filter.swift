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

	var status: Status

	var isAchieved: Bool = false

	var icon: Icon

	var matchType: MatchType

	// MARK: - Relationships

	@Relationship(deleteRule: .cascade)
	var tags: [Tag] = []

	// MARK: - Additional Info

	var creationDate: Date

	var index: Int

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		title: String = "",
		status: Status = .any,
		isAchieved: Bool = false,
		matchType: MatchType = .any,
		icon: Icon = .none,
		creationDate: Date = .now,
		index: Int = 0
	) {
		self.uuid = uuid
		self.title = title
		self.status = status
		self.isAchieved = isAchieved
		self.matchType = matchType
		self.icon = icon
		self.creationDate = creationDate
		self.index = index
	}
}
