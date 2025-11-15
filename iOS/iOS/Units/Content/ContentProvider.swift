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

	private let tagsProvider: ModelsProvider<Tag>?

	let payload: ContentPayload

	// MARK: - Initialization

	init(payload: ContentPayload, container: any PersistentContainer) {
		self.payload = payload

		switch payload {
		case .all:
			self.itemsProvider = ModelsProvider(container: container, request: ItemsRequest(fetchLimit: nil, tag: nil))
			self.tagsProvider = nil
		case let .tag(id):
			self.itemsProvider = ModelsProvider(container: container, request: ItemsRequest(fetchLimit: nil, tag: id))
			self.tagsProvider = ModelsProvider(container: container, request: TagsRequest(uuid: id))
		}

		configure()
	}
}

// MARK: - Public Interface
extension ContentProvider {

	func fetchContent() {
		Task {
			try? await itemsProvider.fetchData()
		}
		guard case .tag = payload else {
			delegate?.providerDidChangeContent(content: .all)
			return
		}
		Task {
			try? await tagsProvider?.fetchData()
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

		guard let tagsProvider else {
			return
		}

		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in await tagsProvider.stream() {
				guard let tag = change.first else {
					continue
				}
				self.delegate?.providerDidChangeContent(content: .tag(tag: tag))
			}
		}
	}
}

enum Content {
	case all
	case tag(tag: Tag)
}
