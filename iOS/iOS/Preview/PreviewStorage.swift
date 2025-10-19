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
		Array(repeating: Item(uuid: .init(), title: "Default Item"), count: 240)
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return .init(uuid: .init(), title: "First Item")
	}

	func fecthLists() async throws -> [List] {
		[
			.init(uuid: UUID(), name: "Backlog"),
			.init(uuid: UUID(), name: "Today")
		]
	}
}
