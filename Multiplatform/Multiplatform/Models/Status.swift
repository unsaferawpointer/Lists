//
//  Status.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 07.01.2026.
//

import Foundation

enum Status: Int {
	case any = 0
	case completed
	case incomplete
}

// MARK: - CaseIterable
extension Status: CaseIterable { }

// MARK: - Codable
extension Status: Codable { }

// MARK: - Identifiable
extension Status: Identifiable {

	var id: RawValue {
		rawValue
	}
}

extension Status {

	var name: String {
		switch self {
		case .any:
			"Any"
		case .completed:
			"Completed"
		case .incomplete:
			"Incomplete"
		}
	}
}
