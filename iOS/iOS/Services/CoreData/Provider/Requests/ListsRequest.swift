//
//  ListsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

struct ListsRequest { }

// MARK: - ObjectsRequest
extension ListsRequest: ObjectsRequest {

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
