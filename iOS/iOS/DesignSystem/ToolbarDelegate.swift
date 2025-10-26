//
//  ToolbarDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.10.2025.
//

import UIKit

protocol ToolbarDelegate: AnyObject {
	func didSelectToolbarItem(with identifier: String, state: UIMenuElement.State)
	func getToolbarModel() -> ContentToolbarModel
}
