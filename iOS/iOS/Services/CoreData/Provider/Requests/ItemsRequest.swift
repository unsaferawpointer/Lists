//
//  ItemsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation

struct ItemsRequest {
	let fetchLimit: Int?
	let tag: UUID?
}

// MARK: - RequestRepresentable
extension ItemsRequest: RequestRepresentable {

	var nsPredicate: NSPredicate? {
		guard let id = tag else {
			return nil
		}
		return NSPredicate(format: "ANY tags.uuid == %@", id as CVarArg)
	}
	
	var nsSortDescriptors: [NSSortDescriptor]? {
		return [NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true)]
	}

}
