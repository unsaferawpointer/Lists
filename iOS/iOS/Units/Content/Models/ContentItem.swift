//
//  ContentItem.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

struct ContentItem {
	let uuid: UUID
	let title: String
	let isStrikethrough: Bool
}

// MARK: - Identifiable
extension ContentItem: Identifiable {

	var id: UUID {
		return uuid
	}
}

// MARK: - Configuration
extension ContentItem {

	var configuration: UIListContentConfiguration {
		var result = UIListContentConfiguration.cell()
		result.text = title
		return result
	}
}
