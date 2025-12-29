//
//  Icon.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 29.12.2025.
//

import Foundation

enum Icon: Int, Codable {

	case none
	case star
	case folder
	case bolt
}

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
			"custom.list.bullet"
		case .star:
			"star"
		case .folder:
			"folder"
		case .bolt:
			"bolt"
		}
	}
}
