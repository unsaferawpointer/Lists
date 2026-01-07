//
//  FilterEditor + Model.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 02.01.2026.
//

import Foundation
import SwiftData

extension FilterEditor {

	struct Model {
		var name: String
		var icon: Icon
		var status: Status
		var matchType: MatchType
		var tags: Set<PersistentIdentifier>
	}
}
