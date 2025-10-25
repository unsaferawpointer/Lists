//
//  RelativeDestination.swift
//  iOS
//
//  Created by Anton Cherkasov on 25.10.2025.
//

import Foundation

enum RelativeDestination<T: Hashable> {
	case after(id: T)
	case before(id: T)
}

// MARK: - Computed Properties
extension RelativeDestination {

	var id: T {
		switch self {
		case let .after(id):	id
		case let .before(id):	id
		}
	}
}
