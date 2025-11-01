//
//  Storage.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation
import CoreData

enum ItemChange {
	case text(value: String)
	case strikethrough(value: Bool)
}

protocol StorageProtocol {

	// MARK: - Add

	func addItem(_ item: Item, to listId: UUID?) async throws
	func addList(_ list: List) async throws

	// MARK: - Delete

	func deleteItems(with ids: [UUID]) async throws
	func deleteList(with id: UUID) async throws

	// MARK: - Modificate

	func updateItems(with ids: [UUID], change: ItemChange) async throws
	func updateList(with id: UUID, properties: List.Properties) async throws

	// MARK: - Move

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func moveItems(with ids: [UUID], to list: UUID?) async throws
}


final class Storage {

	// MARK: - Converters

	private let itemConverter: any Converter<ItemEntity, Item> = ItemsConverter()

	private let listConverter: any Converter<ListEntity, List> = ListsConverter()

	// MARK: - Stored Properties

	private let container: NSPersistentContainer

	// MARK: - Initialization

	init(container: NSPersistentContainer) {
		self.container = container
	}
}

// MARK: - Computed Properties
private extension Storage { }

// MARK: - StorageProtocol
extension Storage: StorageProtocol {

	func addItem(_ item: Item, to listId: UUID?) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			let newEntity = itemConverter.newEntity(for: item, in: context)

			let sortDescriptor = NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: false)
			if let lastItem = fetchEntity(type: ItemEntity.self, in: context, sort: [sortDescriptor]) {
				newEntity.offset = lastItem.offset + 1
			}

			guard let listId, let list = fetchEntity(type: ListEntity.self, with: listId, in: context) else {
				try context.save()
				return
			}
			newEntity.list = list
			try context.save()
		}
	}

	// MARK: - Add

	func addList(_ list: List) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			let _ = listConverter.newEntity(for: list, in: context)
			try context.save()
		}
	}

	// MARK: - Delete

	func deleteItems(with ids: [UUID]) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			try deleteEntities(type: ItemEntity.self, with: ids, in: context)
			try context.save()
		}
	}

	func deleteList(with id: UUID) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			try deleteEntities(type: ListEntity.self, with: [id], in: context)
			try context.save()
		}
	}

	// MARK: - Update

	func updateItems(with ids: [UUID], change: ItemChange) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			let entities = fetchEntities(type: ItemEntity.self, with: ids, in: context)
			for entity in entities {
				switch change {
				case let .text(value):
					entity.text = value
				case let .strikethrough(value):
					entity.isStrikethrough = value
				}
			}
			try context.save()
		}
	}

	func updateList(with id: UUID, properties: List.Properties) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			guard let entity = fetchEntity(type: ListEntity.self, with: id, in: context) else {
				return
			}
			entity.name = properties.name
			entity.icon = properties.icon
			try context.save()
		}
	}

	// MARK: - Move

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }

			var entities = fetchEntities(type: ItemEntity.self, with: nil, in: context)
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			guard let targetOffset = entities.firstIndex(where: { $0.uuid == destination.id }),
				  let sourceOffset = entities.firstIndex(where: { $0.uuid == id }) else {
				return
			}

			switch destination {
			case .after:
				entities.move(from: sourceOffset, to: targetOffset + 1)
			case .before:
				entities.move(from: sourceOffset, to: targetOffset)
			}
			for (index, entity) in entities.enumerated() {
				entity.offset = Int64(index)
			}
			try context.save()
		}
	}

	func moveItems(with ids: [UUID], to list: UUID?) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }

			let entities = fetchEntities(type: ItemEntity.self, with: nil, in: context)
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			let listEntity: ListEntity? = if let list {
				fetchEntity(type: ListEntity.self, with: list, in: context)
			} else {
				nil
			}

			let moving = entities.compactMap { entity -> ItemEntity? in
				guard let uuid = entity.uuid else {
					return nil
				}
				return ids.contains(uuid) ? entity : nil
			}

			moving.forEach { $0.list = listEntity }
			try context.save()
		}
	}
}

// MARK: - Helpers
private extension Storage {

	func fetchEntity<T: NSManagedObject>(type: T.Type, in context: NSManagedObjectContext, sort sortDescriptors: [NSSortDescriptor]) -> T? {
		let request = T.fetchRequest()
		request.sortDescriptors = sortDescriptors
		request.fetchLimit = 1

		let entities = try? context.fetch(request) as? [T]
		return entities?.first
	}

	func fetchEntities<T: NSManagedObject>(type: T.Type, with ids: [UUID]?, in context: NSManagedObjectContext) -> [T] {

		let request: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
		request.predicate = if let ids {
			NSPredicate(format: "uuid IN %@", ids)
		} else {
			nil
		}

		let entities = try? context.fetch(request)
		return entities ?? []
	}

	func fetchEntity<T: NSManagedObject>(type: T.Type, with id: UUID, in context: NSManagedObjectContext) -> T? {
		let request = T.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
		request.fetchLimit = 1

		let entities = try? context.fetch(request) as? [T]
		return entities?.first
	}

	func deleteEntities<T: NSManagedObject>(type: T.Type, with ids: [UUID], in context: NSManagedObjectContext) throws {
		let entities = fetchEntities(type: type, with: ids, in: context)
		for entity in entities {
			context.delete(entity)
		}
	}
}
