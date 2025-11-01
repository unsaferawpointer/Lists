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

	func map<C>(block: (T) -> C?) -> RelativeDestination<C>? {
		switch self {
		case let .after(id):
			guard let newValue = block(id) else {
				return nil
			}
			return .after(id: newValue)
		case let .before(id):
			guard let newValue = block(id) else {
				return nil
			}
			return .before(id: newValue)
		}
	}
}
