//
//  ItemsPredicate.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 31.12.2025.
//

import Foundation
import SwiftData

enum ItemsPredicate {
	case all
	case inProject(id: PersistentIdentifier)
	case filter(tags: Set<UUID>, matchType: MatchType)
}

extension ItemsPredicate: Hashable { }

extension ItemsPredicate {

	var predicate: Predicate<Item> {
		switch self {
		case .all:
			let predicate = #Predicate<Item> { _ in true }
			return predicate
		case let .inProject(id):
			let predicate = #Predicate<Item> { item in
				item.project?.id == id
			}
			return predicate
		case let .filter(tags, matchType):
			guard !tags.isEmpty else {
				return #Predicate<Item> { _ in true }
			}
			switch matchType {
			case .any:
				return #Predicate<Item> { item in
					item.tags.contains { tag in
						tags.contains(tag.uuid)
					}
				}
			case .all:
				return #Predicate<Item> { item in
					item.tags.filter { tag in
						tags.contains(tag.uuid)
					}.count == tags.count
				}
			case .not:
				return #Predicate<Item> { item in
					!item.tags.contains { tag in
						tags.contains(tag.uuid)
					}
				}
			}
		}
	}
}
