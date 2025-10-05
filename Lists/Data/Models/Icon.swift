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
		case .noIcon:
			return "folder"
		case .folder:
			return "folder"
		case .tray:
			return "tray.full"
		case .document:
			return "text.document"
		case .textPage:
			return "text.page"
		}
	}
}

