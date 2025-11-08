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
}

// MARK: - RequestRepresentable
extension ItemsRequest: RequestRepresentable {

	var nsPredicate: NSPredicate? {
		guard let id = list else {
			return nil
		}
		return NSPredicate(format: "list.uuid == %@", argumentArray: [id])
	}
	
	var nsSortDescriptors: [NSSortDescriptor]? {
		return [NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true)]
	}

}
