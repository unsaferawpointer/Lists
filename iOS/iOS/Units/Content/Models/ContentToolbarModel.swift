//
//  ContentToolbarModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.10.2025.
//

import UIKit

struct ContentToolbarModel {
	let secondary: Secondary
	let status: Status
}

extension ContentToolbarModel {

	struct Secondary {
		let isEnadled: Bool
		let state: [String: UIMenuElement.State]
	}

	struct Status {
		let title: String
	}
}
