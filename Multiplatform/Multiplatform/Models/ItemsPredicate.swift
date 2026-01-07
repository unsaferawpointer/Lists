//
//  ItemsPredicate.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 31.12.2025.
//

import Foundation
import SwiftData

struct ItemsPredicate {

	var type: `Type`
	var status: Status

	init(type: Type, status: Status = .any) {
		self.type = type
		self.status = status
	}
}

extension ItemsPredicate {

	enum `Type`: Hashable {
		case all
		case inProject(id: PersistentIdentifier)
		case filter(tags: Set<UUID>, matchType: MatchType)
	}
}

extension ItemsPredicate: Hashable { }

extension ItemsPredicate {

	var predicate: Predicate<Item> {
		switch type {
		case .all:
			switch status {
			case .any:
				return #Predicate<Item> { _ in true }
			case .completed:
				return #Predicate<Item> { $0.isCompleted }
			case .incomplete:
				return #Predicate<Item> { !$0.isCompleted }
			}
		case let .inProject(id):
			switch status {
			case .any:
				return #Predicate<Item> { item in
					item.project?.id == id
				}
			case .completed:
				return #Predicate<Item> { item in
					item.project?.id == id && item.isCompleted
				}
			case .incomplete:
				return #Predicate<Item> { item in
					item.project?.id == id && !item.isCompleted
				}
			}
		case let .filter(tags, matchType):
			guard !tags.isEmpty else {
				switch status {
				case .any:
					return #Predicate<Item> { _ in true }
				case .completed:
					return #Predicate<Item> { $0.isCompleted }
				case .incomplete:
					return #Predicate<Item> { !$0.isCompleted }
				}
			}
			switch matchType {
			case .any:
				switch status {
				case .any:
					return #Predicate<Item> { item in
						item.tags.contains { tag in
						 tags.contains(tag.uuid)
					 }
				 }
				case .completed:
					return #Predicate<Item> { item in
						item.tags.contains { tag in
							tags.contains(tag.uuid)
						} && item.isCompleted
					}
				case .incomplete:
					return #Predicate<Item> { item in
						item.tags.contains { tag in
							tags.contains(tag.uuid)
						} && !item.isCompleted
					}
				}
			case .all:
				switch status {
				case .any:
					return #Predicate<Item> { item in
						item.tags.filter { tag in
							tags.contains(tag.uuid)
						}.count == tags.count
				 }
				case .completed:
					return #Predicate<Item> { item in
						item.tags.filter { tag in
							tags.contains(tag.uuid)
						}.count == tags.count && item.isCompleted
					}
				case .incomplete:
					return #Predicate<Item> { item in
						item.tags.filter { tag in
							tags.contains(tag.uuid)
						}.count == tags.count && !item.isCompleted
					}
				}
			case .not:
				switch status {
				case .any:
					return #Predicate<Item> { item in
						!item.tags.contains { tag in
							tags.contains(tag.uuid)
						}
				 }
				case .completed:
					return #Predicate<Item> { item in
						!item.tags.contains { tag in
							tags.contains(tag.uuid)
						} && item.isCompleted
					}
				case .incomplete:
					return #Predicate<Item> { item in
						!item.tags.contains { tag in
							tags.contains(tag.uuid)
						} && !item.isCompleted
					}
				}
			}
		}
	}
}
