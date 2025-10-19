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
	func fecthLists() async throws -> [List]
}


final class Storage {

	static let shared = Storage()

	// MARK: - Data

	private var lists: [List] = [.init(uuid: .init(), name: UUID().uuidString)]

	// MARK: - Initialization

	private init() { }
}

// MARK: - StorageProtocol
extension Storage: StorageProtocol {

	func fetchItems(in list: UUID?) async throws -> [Item] {
		return []
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return nil
	}

	func fecthLists() async throws -> [List] {
		return lists
	}
}
