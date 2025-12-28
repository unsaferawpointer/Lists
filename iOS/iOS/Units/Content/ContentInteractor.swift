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
	func setList(items ids: [UUID], list: UUID?) async throws
	func setTags(_ tags: Set<UUID>, for items: [UUID]) async throws

	var presenter: ContentPresenterProtocol? { get set }
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let payload: ContentPayload

	private let dataManager: DataManager

	private let itemsProvider: ItemsProvider

	// MARK: - Initialization

	init(
		payload: ContentPayload,
		dataManager: DataManager,
		itemsProvider: ItemsProvider
	) {
		self.payload = payload
		self.dataManager = dataManager
		self.itemsProvider = itemsProvider

		Task {
			for await _ in itemsProvider.stream {
				try? await fetchItems()
			}
		}
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func item(for id: UUID) async throws -> Item? {
		return nil
	}

	@MainActor
	func fetchItems() async throws {
		let items = try await itemsProvider.fetchItems()
		presenter?.present(items: items)
	}

	func addItem(with properties: Item.Properties) async throws {
		try await dataManager.insertItem(
			id: UUID(),
			properties: properties,
			to: payload.listID
		)
	}

	func setText(_ text: String, for item: UUID) async throws {
		try await dataManager.updateItems(ids: [item], text: text)
	}

	func strikeThroughItems(with ids: [UUID], flag: Bool) async throws {
		if flag {
			try await dataManager.updateItems(ids: ids, insert: .strikethrough)
		} else {
			try await dataManager.updateItems(ids: ids, remove: .strikethrough)
		}
	}

	func deleteItems(with ids: [UUID]) async throws {
		try await dataManager.deleteItems(ids: ids)
	}

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await dataManager.moveItem(with: id, to: destination)
	}

	func setList(items ids: [UUID], list: UUID?) async throws {
		try await dataManager.updateItems(ids: ids, list: list)
	}

	func setTags(_ tags: Set<UUID>, for items: [UUID]) async throws {
		try await dataManager.updateItems(ids: items, tags: tags)
	}
}
