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
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let payload: ContentPayload

	private let storage: StorageProtocol

	private let contentProvider: ContentProvider

	// MARK: - Initialization

	init(
		payload: ContentPayload,
		storage: StorageProtocol,
		contentProvider: ContentProvider
	) {
		self.payload = payload
		self.storage = storage
		self.contentProvider = contentProvider

		contentProvider.delegate = self
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func item(for id: UUID) async throws -> Item? {
		try? await contentProvider.item(for: id)
	}

	func fetchItems() async throws {
		contentProvider.fetchContent()
	}

	func addItem(with properties: Item.Properties) async throws {
		let newItem = Item(uuid: UUID(), properties: properties, tags: [])
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

	func setList(items ids: [UUID], list: UUID?) async throws {
		try await storage.setList(items: ids, list: list)
	}

	func setTags(_ tags: Set<UUID>, for items: [UUID]) async throws {
		try await storage.setTags(tags, for: items)
	}
}

// MARK: - ContentProviderDelegate
extension ContentInteractor: ContentProviderDelegate {

	func providerDidChangeContent(content: Content) {
		presenter?.present(content: content)
	}
	
	func providerDidChangeItems(items: [Item]) {
		presenter?.present(items: items)
	}
}
