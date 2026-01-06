//
//  MatchType.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 02.01.2026.
//

enum MatchType: Int {
	case any = 0
	case all
	case not
}

// MARK: - CaseIterable
extension MatchType: CaseIterable { }

// MARK: - Codable
extension MatchType: Codable { }

// MARK: - Identifiable
extension MatchType: Identifiable {

	var id: RawValue {
		rawValue
	}
}

extension MatchType {

	var name: String {
		switch self {
		case .any:
			"Any"
		case .all:
			"All"
		case .not:
			"Not"
		}
	}
}
