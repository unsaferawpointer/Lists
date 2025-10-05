//
//  ItemEntity.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import Foundation
import SwiftData

@Model
final class ItemEntity {

	var timestamp: Date

	var title: String

	var subtitle: String?

	@Relationship(deleteRule: .nullify)
	var list: ListEntity?

	// MARK: - Initialization

	init(timestamp: Date, title: String, subtitle: String? = nil, list: ListEntity?) {
		self.timestamp = timestamp
		self.title = title
		self.subtitle = subtitle
		self.list = list
	}
}
