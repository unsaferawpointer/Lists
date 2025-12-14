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
	case filter(id: UUID)
}

// MARK: - RawRepresentable
extension ContentPayload: RawRepresentable {

	typealias RawValue = String

	init?(rawValue: String) {
		switch rawValue {
		case "all":
			self = .all
		default:
			let components = rawValue.split(separator: "")
			guard components.count == 2 else {
				return nil
			}

			guard let id = UUID(uuidString: String(components[1])) else {
				return nil
			}

			switch components[0] {
			case "filter":
				self = .filter(id: id)
			case "list":
				self = .list(id: id)
			default:
				return nil
			}
		}
	}

	var rawValue: String {
		switch self {
		case .all:
			"all"
		case let .list(id):
			"list:\(id.uuidString)"
		case let .filter(id):
			"filter:\(id.uuidString)"
		}
	}
}

// MARK: - Computed Properties
extension ContentPayload {

	var listID: UUID? {
		switch self {
		case let .list(id):		id
		default:				nil
		}
	}

	var filterID: UUID? {
		switch self {
		case let .filter(id):	id
		default:				nil
		}
	}
}
