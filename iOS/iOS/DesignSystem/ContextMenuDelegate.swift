//
//  ContextMenuDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import UIKit

protocol ContextMenuDelegate: AnyObject {
	func contextMenuSelected(menuItem: String, with selection: [UUID], state: UIMenuElement.State)
	func state(for menuItem: String, with id: UUID) -> UIMenuElement.State
}
