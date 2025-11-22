//
//  ContentProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

protocol ContentProviderDelegate: AnyObject {
	func providerDidChangeContent(content: Content)
	func providerDidChangeItems(items: [Item])
}

final class ContentProvider {

	weak var delegate: ContentProviderDelegate?

	// MARK: - DI by Initialization

	private let itemsProvider: ModelsProvider<Item>

	private let listsProvider: ModelsProvider<List>

	let payload: ContentPayload

	// MARK: - Initialization

	init(payload: ContentPayload, container: any PersistentContainer) {
		self.payload = payload

		let request = switch payload {
		case .all:
			ItemsRequest(fetchLimit: nil, list: nil)
		case .list(let id):
			ItemsRequest(fetchLimit: nil, list: id)
		}

		self.itemsProvider = ModelsProvider(container: container, request: request)
		self.listsProvider = ModelsProvider(container: container, request: ListsRequest(uuid: nil))

		configure()
	}
}

// MARK: - Public Interface
extension ContentProvider {

	func fetchContent() {
		Task {
			try? await listsProvider.fetchData()
			try? await itemsProvider.fetchData()
		}
	}

	func item(for id: UUID) async throws -> Item? {
		await itemsProvider.item(for: id)
	}
}

// MARK: - Helpers
private extension ContentProvider {

	func configure() {
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in await itemsProvider.stream() {
				self.delegate?.providerDidChangeItems(items: change)
			}
		}
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in await listsProvider.stream() {
				try? await itemsProvider.fetchData()
				guard let listID = payload.listID else {
					self.delegate?.providerDidChangeContent(content: .all)
					continue
				}
				guard let list = change.first(where: { $0.id == listID }) else {
					continue
				}
				self.delegate?.providerDidChangeContent(content: .list(list: list))
			}
		}
	}
}

enum Content {
	case all
	case list(list: List)
}
