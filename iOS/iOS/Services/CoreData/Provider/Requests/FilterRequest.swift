//
//  FilterRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.12.2025.
//

import Foundation

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
