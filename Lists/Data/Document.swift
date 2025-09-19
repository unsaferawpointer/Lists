//
//  Document.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation
import SwiftData

@Model
final class Document {

	var id: UUID?

	var name: String?

	// MARK: - Initialization

	init(
		id: UUID? = UUID(),
		name: String?
	) {
		self.id = id
		self.name = name
	}
}
