//
//  ListValidator.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import Foundation

final class ListValidator {

	let minNameLength: Int = 1
	let maxNameLength: Int = 32

	func validate(name: String) -> Bool {
		let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.count < maxNameLength && trimmed.count > minNameLength
	}
}
