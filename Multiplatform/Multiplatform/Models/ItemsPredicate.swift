//
//  ItemsPredicate.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 31.12.2025.
//

import Foundation
import SwiftData

enum ItemsPredicate {
	case all
	case inProject(id: PersistentIdentifier)
}

extension ItemsPredicate: Hashable { }

extension ItemsPredicate {

	var predicate: Predicate<Item> {
		switch self {
		case .all:
			let predicate = #Predicate<Item> { _ in true }
			return predicate
		case let .inProject(id):
			let predicate = #Predicate<Item> { item in
				item.project?.id == id
			}
			return predicate
		}
	}
}
