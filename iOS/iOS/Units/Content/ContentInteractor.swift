//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentInteractorProtocol {
	func fetchItems() async throws
	func addItem(with properties: Item.Properties) async throws
	func item(for id: UUID) async throws -> Item?
	func setText(_ text: String, for item: UUID) async throws
	func strikeThroughItems(with ids: [UUID], flag: Bool) async throws
	func deleteItems(with ids: [UUID]) async throws
	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func moveItems(with ids: [UUID], to list: UUID?) async throws
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let payload: ContentPayload

	private let storage: StorageProtocol

	private let itemsProvider: DataProvider<Item, ItemEntity>

	private let listsProvider: DataProvider<List, ListEntity>?

	// MARK: - Initialization

	init(
		payload: ContentPayload,
		storage: StorageProtocol,
		itemsProvider: DataProvider<Item, ItemEntity>,
		listsProvider: DataProvider<List, ListEntity>?
	) {
		self.payload = payload
		self.storage = storage
		self.itemsProvider = itemsProvider
		self.listsProvider = listsProvider

		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in itemsProvider.contentChanges {
				presenter?.present(items: change)
			}
		}

		guard let listsProvider else {
			return
		}

		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in listsProvider.contentChanges {
				guard let list = change.first else {
					continue
				}
				presenter?.present(list: list)
			}
		}
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func item(for id: UUID) async throws -> Item? {
		itemsProvider.firstItem { $0.id == id }
	}

	func fetchItems() async throws {
		itemsProvider.fetch()
		listsProvider?.fetch()
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

	func moveItems(with ids: [UUID], to list: UUID?) async throws {
		try await storage.moveItems(with: ids, to: list)
	}
}
