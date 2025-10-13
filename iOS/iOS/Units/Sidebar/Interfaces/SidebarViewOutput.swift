//
//  SidebarViewOutput.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import Foundation

protocol SidebarViewDelegate: AnyObject {
	func didSelectItem(_ indexPath: IndexPath)
}
