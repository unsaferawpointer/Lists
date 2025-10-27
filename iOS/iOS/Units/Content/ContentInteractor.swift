//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentInteractorProtocol {
	func fetchItems() async throws -> [Item]
	func addItem(with properties: Item.Properties) async throws
	func setText(_ text: String, for item: UUID) async throws
	func strikeThroughItems(with ids: [UUID], flag: Bool) async throws
	func deleteItems(with ids: [UUID]) async throws
	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let payload: ContentPayload

	private let storage: StorageProtocol

	private let dataProvider: DataProvider<Item, ItemEntity>

	// MARK: - Initialization

	init(payload: ContentPayload, storage: StorageProtocol, dataProvider: DataProvider<Item, ItemEntity>) {
		self.payload = payload
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

	func addItem(with properties: Item.Properties) async throws {
		let newItem = Item(uuid: UUID(), properties: properties)
		try await storage.addItem(newItem, to: payload.listID)
	}

	func setText(_ text: String, for item: UUID) async throws {
		let change: ItemChange = .text(value: text)
		try await storage.updateItems(with: [item], change: change)
	}

	func strikeThroughItems(with ids: [UUID], flag: Bool) async throws {
		let change: ItemChange = .strikethrough(value: flag)
		try await storage.updateItems(with: ids, change: change)
	}

	func deleteItems(with ids: [UUID]) async throws {
		try await storage.deleteItems(with: ids)
	}

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await storage.moveItem(with: id, to: destination)
	}
}
