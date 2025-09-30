//
//  ItemEntity.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation
import SwiftData

@Model
final class ItemEntity {

	var uuid: UUID
	var text: String?

	var parent: ItemEntity?

	@Relationship(deleteRule: .cascade, inverse: \ItemEntity.parent)
	var subitems: [ItemEntity] = []

	// MARK: - Initialization

	init (uuid: UUID = UUID(), text: String? = nil, parent: ItemEntity? = nil, subitems: [ItemEntity] = []) {
		self.uuid = uuid
		self.text = text
		self.parent = parent
		self.subitems = subitems
	}
}
