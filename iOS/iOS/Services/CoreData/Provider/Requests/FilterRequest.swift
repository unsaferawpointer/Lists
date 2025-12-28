//
//  FilterRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation
import CoreData

struct FiltersRequest { }

// MARK: - ObjectsRequest
extension FiltersRequest: ObjectsRequest {

	typealias Entity = FilterEntity

	var value: NSFetchRequest<FilterEntity> {
		return FilterEntity.fetchRequest()
	}
}

struct FilterRequest {

	let identifier: UUID

	init(identifier: UUID) {
		self.identifier = identifier
	}
}

// MARK: - ObjectsRequest
extension FilterRequest: ObjectsRequest {

	typealias Entity = FilterEntity

	var value: NSFetchRequest<FilterEntity> {
		let request = FilterEntity.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [identifier])
		return request
	}
}
