//
//  NavigationItem.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

struct NavigationItem {

	let id: Identifier

	let iconName: String
	let title: String

	// MARK: - Initialization

	init(
		id: Identifier,
		iconName: String,
		title: String,
	) {
		self.id = id
		self.iconName = iconName
		self.title = title
	}
}

// MARK: - Nested Data Structs
extension NavigationItem {

	enum Identifier: Hashable {
		case all
		case list(id: UUID)
	}
}

// MARK: - Identifiable
extension NavigationItem: Identifiable { }

// MARK: - Configuration
extension NavigationItem {

	var configuration: UIListContentConfiguration {
		var result = UIListContentConfiguration.cell()
		result.image = UIImage(systemName: iconName)
		result.text = title
		return result
	}
}
