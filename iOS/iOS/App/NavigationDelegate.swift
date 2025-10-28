//
//  NavigationDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.10.2025.
//

import Foundation

protocol NavigationDelegate {
	func didSelect(navigationItem: NavigationItem)
	func updateNavigationName(_ name: String)
}
