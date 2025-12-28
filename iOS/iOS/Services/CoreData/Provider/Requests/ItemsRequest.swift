//
//  ItemsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

struct ItemsRequest {

	let tagsFilter: TagsFilter?

	let itemOptions: ItemOptions?

	let list: UUID?

	// MARK: - Initialization

	init(tagsFilter: TagsFilter? = nil, itemOptions: ItemOptions? = nil, list: UUID? = nil) {
		self.tagsFilter = tagsFilter
		self.itemOptions = itemOptions
		self.list = list
	}
}

// MARK: - ObjectsRequest
extension ItemsRequest: ObjectsRequest {

	typealias Entity = ItemEntity

	var value: NSFetchRequest<Entity> {
		let request = ItemEntity.fetchRequest()

		var predicates: [NSPredicate] = []
		if let itemOptions {
			predicates.append(NSPredicate(format: "rawOptions & %d != 0", argumentArray: [itemOptions.rawValue]))
		}
		if let tagsFilter {

			let tags = tagsFilter.tags

			switch tagsFilter.matchType {
			case .any:
				predicates.append(
					NSPredicate(
						format: "SUBQUERY(tags, $tag, $tag.uuid IN %@).@count > 0",
						argumentArray: [tags]
					)
				)
			case .all:
				predicates.append(
					NSPredicate(
						format: "SUBQUERY(tags, $tag, $tag.uuid IN %@).@count == %d",
						argumentArray: [tags, tags.count]
					)
				)
			case .not:
				predicates.append(
					NSPredicate(
						format: "SUBQUERY(tags, $tag, $tag.uuid IN %@).@count == %d",
						argumentArray: [tags, 0]
					)
				)
			}
		}
		if let list {
			predicates.append(
				NSPredicate(
					format: "list.uuid == %d",
					argumentArray: [list]
				)
			)
		}
		request.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		return request
	}
}
