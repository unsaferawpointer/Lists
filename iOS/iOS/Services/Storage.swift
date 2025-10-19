//
//  Storage.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol StorageProtocol {
	func fetchItems(in list: UUID?) async throws -> [Item]
	func fetchItem(with id: UUID) async throws -> Item?
	func addItem(_ item: Item) async throws
	func setText(_ text: String, for item: UUID) async throws

	func fecthLists() async throws -> [List]
}


final class Storage {

	static let shared = Storage()

	// MARK: - Data

	private var lists: [List] = [.init(uuid: .init(), name: UUID().uuidString)]

	private var items: [Item] = Array(repeating: .init(uuid: UUID(), title: "Defailt Item"), count: 240)

	// MARK: - Initialization

	private init() { }
}

// MARK: - StorageProtocol
extension Storage: StorageProtocol {

	func fetchItems(in list: UUID?) async throws -> [Item] {
		return items
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return items.first(where: { $0.id == id })
	}

	func addItem(_ item: Item) async throws {
		items.append(item)
	}

	func setText(_ text: String, for item: UUID) async throws {
		guard let index = items.firstIndex(where: { $0.id == item }) else {
			return
		}
		items[index].title = text
	}

	func fecthLists() async throws -> [List] {
		return lists
	}
}
