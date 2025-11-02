//
//  Collection+Extension.swift
//  iOS
//
//  Created by Anton Cherkasov on 01.11.2025.
//

import Foundation

extension Collection {

	func firstIndex<T>(where keyPath: KeyPath<Element, T>, equalsTo value: T) -> Index? where T: Equatable {
		return firstIndex { element in
			element[keyPath: keyPath] == value
		}
	}
}
