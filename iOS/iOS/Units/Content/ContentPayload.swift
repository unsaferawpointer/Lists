//
//  ContentPayload.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.10.2025.
//

import Foundation

enum ContentPayload {
	case all
	case list(id: UUID)
}

// MARK: - Computed Properties
extension ContentPayload {

	var listID: UUID? {
		switch self {
		case .all:				nil
		case let .list(id):		id
		}
	}
}

// MARK: - Predicate
extension ContentPayload: Predicate {

	var value: NSPredicate? {
		switch self {
		case .all:
			nil
		case let .list(id):
			NSPredicate(format: "list.uuid == %@", argumentArray: [id])
		}
	}
}
