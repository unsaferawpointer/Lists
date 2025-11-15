//
//  TagOptions.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.11.2025.
//

import Foundation

struct TagOptions: OptionSet {

	var rawValue: Int64
}

// MARK: - Templates
extension TagOptions {

	static let isArchived: TagOptions = .init(rawValue: 1 << 10)
}
