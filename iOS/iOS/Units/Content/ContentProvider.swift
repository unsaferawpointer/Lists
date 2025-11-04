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

	private let itemsProvider: ItemsObserver

	private let listsProvider: ListsObserver?

	let payload: ContentPayload

	// MARK: - Initialization

	init(payload: ContentPayload, container: any PersistentContainer) {
		self.payload = payload

		switch payload {
		case .all:
			self.itemsProvider = ItemsObserver(container: container, request: .init(fetchLimit: nil, list: nil))
			self.listsProvider = nil
		case let .list(id):
			self.itemsProvider = ItemsObserver(container: container, request: .init(fetchLimit: nil, list: id))
			self.listsProvider = ListsObserver(container: container, request: .init(fetchLimit: 1, uuid: id))
		}

		configure()
	}
}

// MARK: - Public Interface
extension ContentProvider {

	func fetchContent() {
		itemsProvider.fetchData()
		guard case .list = payload else {
			delegate?.providerDidChangeContent(content: .all)
			return
		}
		listsProvider?.fetchData()
	}

	func item(for id: UUID) async throws -> Item? {
		itemsProvider.item(for: id)
	}
}

// MARK: - Helpers
private extension ContentProvider {

	func configure() {
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in itemsProvider.stream() {
				self.delegate?.providerDidChangeItems(items: change)
			}
		}

		guard let listsProvider else {
			return
		}

		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in listsProvider.stream() {
				guard let list = change.first else {
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
