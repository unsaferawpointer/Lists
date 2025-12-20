//
//  ListsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

struct ListsRequest {
	let uuid: UUID?
}

// MARK: - RequestRepresentable
extension ListsRequest: RequestRepresentable {

	typealias Entity = ListEntity

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
		return [NSSortDescriptor(keyPath: \ListEntity.offset, ascending: true)]
	}
}

struct ListsRequestV2 { }

// MARK: - ObjectsRequest
extension ListsRequestV2: ObjectsRequest {

	typealias Entity = ListEntity

	var value: NSFetchRequest<ListEntity> {
		return ListEntity.fetchRequest()
	}
}

struct ListRequest {

	let identifier: UUID

	init(identifier: UUID) {
		self.identifier = identifier
	}
}

// MARK: - ObjectsRequest
extension ListRequest: ObjectsRequest {

	typealias Entity = ListEntity

	var value: NSFetchRequest<ListEntity> {
		let request = ListEntity.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [identifier])
		return request
	}
}
