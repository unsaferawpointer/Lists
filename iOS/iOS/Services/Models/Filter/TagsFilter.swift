//
//  TagsFilter.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.12.2025.
//

import Foundation

struct TagsFilter {

	let matchType: MatchType

	let tags: [UUID]

	// MARK: - Initialization

	init(matchType: MatchType, tags: [UUID]) {
		self.matchType = matchType
		self.tags = tags
	}
}

// MARK: - Nested Data Structs
extension TagsFilter {

	enum MatchType: Int64 {
		case any
		case all
		case not
	}
}
