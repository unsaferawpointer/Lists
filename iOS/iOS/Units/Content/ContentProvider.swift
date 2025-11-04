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

	private let itemsProvider: DataProvider<Item>

	private let listsProvider: DataProvider<List>?

	let payload: ContentPayload

	// MARK: - Initialization

	init(payload: ContentPayload, container: NSPersistentContainer) {
		self.payload = payload

		switch payload {
		case .all:
			self.itemsProvider = DataProvider(
				coreDataProvider: CoreDataProvider<ItemEntity>(
					persistentContainer: container,
					sortDescriptors:
						[
							NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
							NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
						],
					predicate: nil
				)
			)
			self.listsProvider = nil
		case let .list(id):
			self.itemsProvider = DataProvider(
				coreDataProvider: CoreDataProvider<ItemEntity>(
					persistentContainer: container,
					sortDescriptors:
						[
							NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
							NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
						],
					predicate: NSPredicate(format: "list.uuid == %@", argumentArray: [id])
				)
			)
			self.listsProvider = DataProvider(
				coreDataProvider: CoreDataProvider<ListEntity>(
					persistentContainer: container,
					sortDescriptors: [NSSortDescriptor(keyPath: \ListEntity.offset, ascending: true)],
					predicate: NSPredicate(format: "uuid == %@", argumentArray: [id]),
					fetchLimit: 1
				)
			)
		}

		configure()
	}
}

// MARK: - Public Interface
extension ContentProvider {

	func fetchContent() {
		itemsProvider.fetch()
		guard case .list = payload else {
			delegate?.providerDidChangeContent(content: .all)
			return
		}
		listsProvider?.fetch()
	}

	func item(for id: UUID) async throws -> Item? {
		itemsProvider.firstItem { $0.id == id }
	}
}

// MARK: - Helpers
private extension ContentProvider {

	func configure() {
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			for await change in itemsProvider.contentChanges {
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
			for await change in listsProvider.contentChanges {
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
