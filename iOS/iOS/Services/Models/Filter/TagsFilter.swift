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

	enum MatchType: Int64, CaseIterable {
		case any
		case all
		case not
	}
}

// MARK: - Identifiable
extension TagsFilter.MatchType: Identifiable {

	var id: RawValue {
		return rawValue
	}
}

// MARK: - Computed Properties
extension TagsFilter.MatchType {

	var title: String {
		switch self {
		case .any:
			return "Any"
		case .all:
			return "All"
		case .not:
			return "Not"
		}
	}

	var description: String {
		switch self {
		case .any:
			"Show if at least one of the selected tags is present"
		case .all:
			"Show only if all selected tags are present"
		case .not:
			"Exclude objects with the specified tags from the selection"
		}
	}
}
