//
//  Availability.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.11.2025.
//

import UIKit

protocol Availability {
	func isEnabled(feature: Feature) -> Bool
}

final class FeatureFacade { }

// MARK: - AvailabilityProvider
extension FeatureFacade: Availability {

	func isEnabled(feature: Feature) -> Bool {
		switch feature {
		case .multipleWindows:
			UIApplication.shared.supportsMultipleScenes
		}
	}
}

enum Feature: String {
	case multipleWindows
}
