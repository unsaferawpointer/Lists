//
//  Icon.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import Foundation

enum Icon: Int, Codable {
	case noIcon = 0
	case folder = 1
	case tray = 2
	case document
	case textPage
	case star
	case stack
}

// MARK: - CaseIterable
extension Icon: CaseIterable { }

// MARK: - Identifiable
extension Icon: Identifiable {

	var id: RawValue {
		return rawValue
	}
}

extension Icon {

	var iconName: String {
		switch self {
		case .noIcon:		"folder"
		case .folder:		"folder"
		case .tray:			"tray.full"
		case .document:		"text.document"
		case .textPage:		"text.page"
		case .star:			"star"
		case .stack:		"square.stack"
		}
	}
}

