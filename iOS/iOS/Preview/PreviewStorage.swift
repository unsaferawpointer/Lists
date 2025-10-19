//
//  PreviewStorage.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

final class PreviewStorage { }

// MARK: - StorageProtocol
extension PreviewStorage: StorageProtocol {

	func fetchItems(in list: UUID?) async throws -> [Item] {
		return []
	}

	func fecthLists() async throws -> [List] {
		[
			.init(uuid: UUID(), name: "Backlog"),
			.init(uuid: UUID(), name: "Today")
		]
	}
}
