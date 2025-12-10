//
//  TagValidator.swift
//  iOS
//
//  Created by Anton Cherkasov on 10.12.2025.
//

import Foundation

final class TagValidator {

	let minNameLength: Int = 1
	let maxNameLength: Int = 64

	func validate(name: String) -> ValidationResult {
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

		// Проверка на пустую строку
		if trimmedName.isEmpty {
			return .failure(.emptyName)
		}

		// Проверка на минимальную длину
		if trimmedName.count < minNameLength {
			return .failure(.tooShort(minimum: minNameLength, actual: trimmedName.count))
		}

		// Проверка на максимальную длину
		if trimmedName.count > maxNameLength {
			return .failure(.tooLong(maximum: maxNameLength, actual: trimmedName.count))
		}

		// Проверка на допустимые символы (опционально)
		if !isValidCharacterSet(trimmedName) {
			return .failure(.invalidCharacters)
		}

		return .success
	}

	private func isValidCharacterSet(_ string: String) -> Bool {
		// Базовый набор допустимых символов - можно настроить под свои нужды
		let allowedCharacterSet = CharacterSet.whitespacesAndNewlines.union(.alphanumerics).union(.punctuationCharacters)
		return string.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) }
	}
}

// MARK: - Nested Data structs
extension TagValidator {

	enum ValidationResult {

		case success
		case failure(Error)

		var isSuccess: Bool {
			if case .success = self {
				return true
			} else {
				return false
			}
		}
	}

	enum Error: Swift.Error, LocalizedError {
		case emptyName
		case tooShort(minimum: Int, actual: Int)
		case tooLong(maximum: Int, actual: Int)
		case invalidCharacters

		var errorDescription: String? {
			switch self {
			case .emptyName:
				return "Tag name cannot be empty"

			case .tooShort(let minimum, let actual):
				return "Tag name is too short. Minimum \(minimum) character\(minimum == 1 ? "" : "s") required, but \(actual) \(actual == 1 ? "was" : "were") provided"

			case .tooLong(let maximum, let actual):
				return "Tag name is too long. Maximum \(maximum) characters allowed, but \(actual) were provided"

			case .invalidCharacters:
				return "Tag name contains invalid characters. Please use only letters, numbers, and common punctuation"
			}
		}

		var recoverySuggestion: String? {
			switch self {
			case .emptyName:
				return "Please enter a name for your tag"

			case .tooShort:
				return "Try adding more characters to the tag name"

			case .tooLong:
				return "Try shortening the tag name or using abbreviations"

			case .invalidCharacters:
				return "Remove any special symbols or emojis from the tag name"
			}
		}
	}
}

