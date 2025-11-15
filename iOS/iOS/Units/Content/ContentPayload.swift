//
//  ContentPayload.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.10.2025.
//

import Foundation

enum ContentPayload {
	case all
	case tag(id: UUID)
}

// MARK: - RawRepresentable
extension ContentPayload: RawRepresentable {

	typealias RawValue = String

	init?(rawValue: String) {
		switch rawValue {
		case "all":
			self = .all
		default:
			guard let id = UUID(uuidString: rawValue) else {
				return nil
			}
			self = .tag(id: id)
		}
	}

	var rawValue: String {
		switch self {
		case .all:
			"all"
		case let .tag(id):
			id.uuidString
		}
	}
}

// MARK: - Computed Properties
extension ContentPayload {

	var tagID: UUID? {
		switch self {
		case .all:				nil
		case let .tag(id):		id
		}
	}
}
