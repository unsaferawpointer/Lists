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

	static let isArchived: ItemOptions = .init(rawValue: 1 << 10)
}

// MARK: - Computed Properties
extension ItemOptions {

	var isStrikethrough: Bool {
		get {
			contains(.strikethrough)
		}
		set {
			if newValue {
				insert(.strikethrough)
			} else {
				remove(.strikethrough)
			}
		}
	}
}
