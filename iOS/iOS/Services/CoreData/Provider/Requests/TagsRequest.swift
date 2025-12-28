//
//  TagsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import Foundation
import CoreData

struct TagsRequest { }

// MARK: - ObjectsRequest
extension TagsRequest: ObjectsRequest {

	typealias Entity = TagEntity

	var value: NSFetchRequest<TagEntity> {
		return TagEntity.fetchRequest()
	}
}
