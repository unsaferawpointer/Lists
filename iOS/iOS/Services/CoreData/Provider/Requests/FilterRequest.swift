//
//  FilterRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation
import CoreData

struct FilterRequest {
	let uuid: UUID?
}

// MARK: - RequestRepresentable
extension FilterRequest: RequestRepresentable {

	typealias Entity = FilterEntity

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
		return [NSSortDescriptor(keyPath: \FilterEntity.title, ascending: true)]
	}
}

struct FiltersRequestV2 { }

// MARK: - ObjectsRequest
extension FiltersRequestV2: ObjectsRequest {

	typealias Entity = FilterEntity

	var value: NSFetchRequest<FilterEntity> {
		return FilterEntity.fetchRequest()
	}
}

struct FilterRequestV2 {

	let identifier: UUID

	init(identifier: UUID) {
		self.identifier = identifier
	}
}

// MARK: - ObjectsRequest
extension FilterRequestV2: ObjectsRequest {

	typealias Entity = FilterEntity

	var value: NSFetchRequest<FilterEntity> {
		let request = FilterEntity.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [identifier])
		return request
	}
}
