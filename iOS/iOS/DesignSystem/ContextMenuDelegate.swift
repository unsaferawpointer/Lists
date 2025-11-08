//
//  ContextMenuDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import Foundation

protocol ContextMenuDelegate: AnyObject {
	func contextMenuSelected(menuItem: String, with selection: [UUID])
}
