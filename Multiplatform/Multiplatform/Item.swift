//
//  Item.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
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
