//
//  Item.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import Foundation
import SwiftData

@Model
final class Item {

	var timestamp: Date

	init(timestamp: Date) {
		self.timestamp = timestamp
	}
}
