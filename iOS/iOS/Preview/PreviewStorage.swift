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

	func setListName(_ name: String, for id: UUID) async throws { }

	func deleteList(with id: UUID) async throws { }

	func addList(with name: String) async throws { }

	func addItem(_ item: Item) async throws { }

	func setText(_ text: String, for item: UUID) async throws { }

	func deleteItems(with ids: [UUID]) async throws { }

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
