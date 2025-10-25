//
//  Array+Extension.swift
//  iOS
//
//  Created by Anton Cherkasov on 25.10.2025.
//

import Foundation

extension Array {

	mutating func move(from source: Index, to target: Index) {
		let adjustedToIndex: Index = source < target
			? target - 1
			: target

		let element = remove(at: source)
		insert(element, at: adjustedToIndex)
	}
}
