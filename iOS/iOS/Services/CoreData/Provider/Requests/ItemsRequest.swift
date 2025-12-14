//
//  ItemsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation

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
