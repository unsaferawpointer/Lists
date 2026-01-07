//
//  Icon.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 29.12.2025.
//

import Foundation

enum Icon: Int, Codable {

	case none = 0
	case star
	case folder
	case bolt
	case archivebox
	case receipt
	case document
	case list
	case calendar
}

// MARK: - CaseIterable
extension Icon: CaseIterable { }

// MARK: - Identifiable
extension Icon: Identifiable {

	var id: Int {
		rawValue
	}
}

// MARK: - Computed Properties
extension Icon {

	var systemName: String {
		switch self {
		case .none:
			"circle.slash"
		case .star:
			"star"
		case .folder:
			"folder"
		case .bolt:
			"bolt"
		case .archivebox:
			"archivebox"
		case .receipt:
			"receipt"
		case .document:
			"document"
		case .list:
			"list.bullet.rectangle.portrait"
		case .calendar:
			"calendar"
		}
	}
}
