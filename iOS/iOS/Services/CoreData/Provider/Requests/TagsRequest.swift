//
//  ListsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation

struct TagsRequest {
	let uuid: UUID?
}

// MARK: - RequestRepresentable
extension TagsRequest: RequestRepresentable {

	typealias Entity = TagEntity

	var fetchLimit: Int? {
		return uuid != nil ? 1 : nil
	}

	var nsPredicate: NSPredicate? {
		guard let id = uuid else {
			return nil
		}
		return NSPredicate(format: "uuid == %@", argumentArray: [id])
	}
	
	var nsSortDescriptors: [NSSortDescriptor]? {
		return [NSSortDescriptor(keyPath: \TagEntity.offset, ascending: true)]
	}
}
