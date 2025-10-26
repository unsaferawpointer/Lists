//
//  ElementIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.10.2025.
//

import UIKit

enum ElementIdentifier: String {
	case newList
	case newItem
	case delete
	case strikeThrough
}

extension UIAction.Identifier {

	init (_ element: ElementIdentifier) {
		self.init(rawValue: element.rawValue)
	}
}
