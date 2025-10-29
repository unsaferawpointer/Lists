//
//  Icon.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.10.2025.
//

import Foundation

enum Icon: Int64 {
	case folder
	case document
	case receipt
	case textPage
	case calendar
	case bookClosed
	case squareStack

	case sunMax
	case cloud
	case flame

	case heart
	case star
	case lightbulb
}

extension Icon {

	var iconName: String {
		switch self {
		case .folder:
			"folder"
		case .document:
			"document"
		case .receipt:
			"receipt"
		case .textPage:
			"text.page"
		case .calendar:
			"calendar"
		case .bookClosed:
			"book.closed"
		case .sunMax:
			"sun.max"
		case .cloud:
			"cloud"
		case .flame:
			"flame"
		case .heart:
			"heart"
		case .star:
			"star"
		case .lightbulb:
			"lightbulb.max"
		case .squareStack:
			"square.stack"
		}
	}
}

// MARK: - CaseIterable
extension Icon: CaseIterable { }
