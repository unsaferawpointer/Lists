//
//  TagsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import Foundation
import CoreData

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

struct TagsRequestV2 { }

// MARK: - ObjectsRequest
extension TagsRequestV2: ObjectsRequest {

	typealias Entity = TagEntity

	var value: NSFetchRequest<TagEntity> {
		return TagEntity.fetchRequest()
	}
}
