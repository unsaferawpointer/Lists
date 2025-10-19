//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentInteractorProtocol {
	func fetchItems() async throws -> [Item]
	func fetchItem(with id: UUID) async throws -> Item?
	func addItem(_ item: Item) async throws
	func setText(_ text: String, for item: UUID) async throws
	func deleteItems(with ids: [UUID]) async throws
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let id: UUID?

	private let storage: StorageProtocol

	// MARK: - Initialization

	init(id: UUID?, storage: StorageProtocol) {
		self.id = id
		self.storage = storage
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchItems() async throws -> [Item] {
		return try await storage.fetchItems(in: id)
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return try await storage.fetchItem(with: id)
	}

	func addItem(_ item: Item) async throws {
		try await storage.addItem(item)
	}

	func setText(_ text: String, for item: UUID) async throws {
		try await storage.setText(text, for: item)
	}

	func deleteItems(with ids: [UUID]) async throws {
		try await storage.deleteItems(with: ids)
	}
}
