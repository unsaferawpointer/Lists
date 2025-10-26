//
//  TableDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.10.2025.
//

import Foundation

protocol TableDelegate: AnyObject {
	func table(didUpdateSelection selection: [UUID])
}
