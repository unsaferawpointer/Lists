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
	func strikeThroughItems(with ids: [UUID]) async throws
	func deleteItems(with ids: [UUID]) async throws
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let id: UUID?

	private let storage: StorageProtocol

	private let dataProvider: DataProvider<Item, ItemEntity>

	// MARK: - Initialization

	init(id: UUID?, storage: StorageProtocol, dataProvider: DataProvider<Item, ItemEntity>) {
		self.id = id
		self.storage = storage
		self.dataProvider = dataProvider

		Task { @MainActor in
			for await change in dataProvider.contentChanges {
				presenter?.present(items: change)
			}
		}
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchItems() async throws -> [Item] {
		dataProvider.fetch()
		return []
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return try await storage.fetchItem(with: id)
	}

	func addItem(_ item: Item) async throws {
		try await storage.addItem(item, to: id)
	}

	func setText(_ text: String, for item: UUID) async throws {
		try await storage.setText(text, for: item)
	}

	func strikeThroughItems(with ids: [UUID]) async throws {
		try await storage.modificate(type: ItemEntity.self, with: ids) { entity in
			entity.isStrikethrough = true
		}
	}

	func deleteItems(with ids: [UUID]) async throws {
		try await storage.deleteItems(with: ids)
	}
}
