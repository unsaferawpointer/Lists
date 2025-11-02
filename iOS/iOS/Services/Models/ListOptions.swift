//
//  ListOptions.swift
//  iOS
//
//  Created by Anton Cherkasov on 02.11.2025.
//

import Foundation

struct ListOptions: OptionSet {

	var rawValue: Int64
}

// MARK: - Templates
extension ListOptions {

	static let isArchived: ListOptions = .init(rawValue: 1 << 10)
}
