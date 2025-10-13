//
//  NavigationItem.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import Foundation

struct NavigationItem {

	let iconName: String

	let title: String

	let isEditable: Bool

	// MARK: - Initialization

	init(iconName: String, title: String, isEditable: Bool = false) {
		self.iconName = iconName
		self.title = title
		self.isEditable = isEditable
	}
}
