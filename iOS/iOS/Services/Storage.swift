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

	func addItem(_ item: Item, to tagId: UUID?) async throws
	func addTag(_ tag: Tag) async throws

	// MARK: - Delete

	func deleteItems(with ids: [UUID]) async throws
	func deleteTag(with id: UUID) async throws

	// MARK: - Modificate

	func updateItems(with ids: [UUID], change: ItemChange) async throws
	func updateTag(with id: UUID, properties: Tag.Properties) async throws

	// MARK: - Move

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) async throws

	// MARK: - Tags

	func setTags(items ids: [UUID], tags: Set<UUID>) async throws
}


final class Storage {

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

	func addItem(_ item: Item, to tagId: UUID?) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			let newEntity = ItemEntity.create(from: item, in: context)

			let sortDescriptor = NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: false)
			if let lastItem = fetchEntity(type: ItemEntity.self, in: context, sort: [sortDescriptor]) {
				newEntity.offset = lastItem.offset + 1
			}

			guard let tagId, let tag = fetchEntity(type: TagEntity.self, with: tagId, in: context) else {
				try context.save()
				return
			}
			newEntity.addToTags(tag)
			try context.save()
		}
	}

	// MARK: - Add

	func addTag(_ tag: Tag) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			let newEntity = TagEntity.create(from: tag, in: context)

			let sortDescriptor = NSSortDescriptor(keyPath: \TagEntity.offset, ascending: false)
			if let lastItem = fetchEntity(type: TagEntity.self, in: context, sort: [sortDescriptor]) {
				newEntity.offset = lastItem.offset + 1
			}
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

	func deleteTag(with id: UUID) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			try deleteEntities(type: TagEntity.self, with: [id], in: context)
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

	func updateTag(with id: UUID, properties: Tag.Properties) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }
			guard let entity = fetchEntity(type: TagEntity.self, with: id, in: context) else {
				return
			}
			entity.title = properties.name
			entity.icon = properties.icon
			try context.save()
		}
	}

	// MARK: - Move

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await moveEntity(type: ItemEntity.self, with: id, to: destination)
	}

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await moveEntity(type: TagEntity.self, with: id, to: destination)
	}

	// MARK: - Tags

	func setTags(items ids: [UUID], tags: Set<UUID>) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }

			let entities = fetchEntities(type: ItemEntity.self, with: nil, in: context)
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			let tagEntities = fetchEntities(type: TagEntity.self, with: nil, in: context)
				.filter { tags.contains($0.id) }
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			let moving = entities.compactMap { entity -> ItemEntity? in
				guard let uuid = entity.uuid else {
					return nil
				}
				return ids.contains(uuid) ? entity : nil
			}

			guard !tagEntities.isEmpty else {
				moving.forEach {
					$0.tags = nil
				}
				try context.save()
				return
			}

			moving.forEach {
				$0.tags = NSSet()
				for tag in tagEntities {
					$0.addToTags(tag)
				}
			}
			try context.save()
		}
	}

	func moveItems(with ids: [UUID], to tag: UUID?) async throws {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else { return }

			let entities = fetchEntities(type: ItemEntity.self, with: nil, in: context)
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			let tagEntity: TagEntity? = if let tag {
				fetchEntity(type: TagEntity.self, with: tag, in: context)
			} else {
				nil
			}

			if tag != nil && tagEntity == nil {
				throw StorageError.tagNotFound
			}

			let moving = entities.compactMap { entity -> ItemEntity? in
				guard let uuid = entity.uuid else {
					return nil
				}
				return ids.contains(uuid) ? entity : nil
			}

			moving.forEach {
				if let tagEntity {
					$0.addToTags(tagEntity)
				}
			}
			try context.save()
		}
	}
}

// MARK: - Helpers
private extension Storage {

	func moveEntity<E: NSManagedObject>(type: E.Type, with id: UUID, to destination: RelativeDestination<UUID>) async throws where E: Identifiable, E.ID == UUID, E: Reorderable {
		try await container.performBackgroundTask { [weak self] context in
			guard let self else {
				return
			}

			var entities = fetchEntities(type: E.self, with: nil, in: context)
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}

			try move(with: id, to: destination, in: &entities)

			for (index, entity) in entities.enumerated() {
				entity.offset = Int64(index)
			}
			try context.save()
		}
	}

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

private extension Storage {

	func move<E>(with id: E.ID, to destination: RelativeDestination<E.ID>, in entities: inout [E]) throws(StorageError) where E: Identifiable {
		var cache: [E.ID: Int] = .init(minimumCapacity: entities.count)
		for (index, entity) in entities.enumerated() {
			cache[entity.id] = index
		}

		guard let targetOffset = cache[destination.id], let sourceOffset = cache[id] else {
			throw .errorWhileMoving
		}

		switch destination {
		case .after:
			entities.move(from: sourceOffset, to: targetOffset + 1)
		case .before:
			entities.move(from: sourceOffset, to: targetOffset)
		}
	}
}
