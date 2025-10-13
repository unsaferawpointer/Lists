//
//  StateProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import Foundation

protocol StateProvider: AnyObject {
	func selectionDidChanged(with index: Int)
}
