//
//  ItemOptions.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import Foundation

struct ItemOptions: OptionSet {

	var rawValue: Int64
}

// MARK: - Templates
extension ItemOptions {

	static let strikethrough: ItemOptions = .init(rawValue: 1 << 0)
}
