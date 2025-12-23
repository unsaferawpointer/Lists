//
//  ItemsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

struct ItemsRequest {
	let fetchLimit: Int?
	let list: UUID?
	let tags: [UUID]?
}

// MARK: - RequestRepresentable
extension ItemsRequest: RequestRepresentable {

	typealias Entity = ItemEntity

	var nsPredicate: NSPredicate? {
		let predicates = [listPredicate, tagsPredicate].compactMap(\.self)
		guard !predicates.isEmpty else {
			return nil
		}
		return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
	}
	
	var nsSortDescriptors: [NSSortDescriptor]? {
		return [NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true)]
	}

}

// MARK: - Helpers
private extension ItemsRequest {

	var listPredicate: NSPredicate? {
		guard let id = list else {
			return nil
		}
		return NSPredicate(format: "list.uuid == %@", id as CVarArg)
	}

	var tagsPredicate: NSPredicate? {
		guard let tags else {
			return nil
		}
		return NSPredicate(format: "ANY tags.uuid IN %@", tags)
	}
}

struct ItemsRequestV2 {

	let tags: [UUID]?

	let itemOptions: ItemOptions?

	// MARK: - Initialization

	init(tags: [UUID]? = nil, itemOptions: ItemOptions? = nil) {
		self.tags = tags
		self.itemOptions = itemOptions
	}
}

// MARK: - ObjectsRequest
extension ItemsRequestV2: ObjectsRequest {

	typealias Entity = ItemEntity

	var value: NSFetchRequest<Entity> {
		let request = ItemEntity.fetchRequest()

		var predicates: [NSPredicate] = []
		if let itemOptions {
			predicates.append(NSPredicate(format: "rawOptions & %d != 0", argumentArray: [itemOptions.rawValue]))
		}
		if let tags {
			predicates.append(NSPredicate(format: "SUBQUERY(tags, $tag, $tag.uuid IN %@).@count == %d", argumentArray: [tags, tags.count]))
		}
		request.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		return request
	}
}
