//
//  Database.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

import Foundation
@preconcurrency import CoreData

protocol DataManager {

	func insertObject<O: ManagedObject>(type: O.Type, properties: O.Properties, relationships: O.Relationships?) async throws

	func updateObjects<R: ObjectsRequest>(request: R, properties: R.Entity.Properties, relationships: R.Entity.Relationships?) async throws

	func deleteObjects<R: ObjectsRequest>(request: R) async throws

	// MARK: - Items

	func insertItem(id: UUID, properties: Item.Properties, to list: UUID?) async throws

	func updateItems<S: Sequence, T: Sequence>(ids: S, tags: T) async throws where S.Element == UUID, T.Element == UUID

	func updateItems<S: Sequence>(ids: S, list: UUID?) async throws where S.Element == UUID

	func updateItems<S: Sequence>(ids: S, remove options: ItemOptions) async throws where S.Element == UUID

	func updateItems<S: Sequence>(ids: S, insert options: ItemOptions) async throws where S.Element == UUID

	func updateItems<S: Sequence>(ids: S, text: String) async throws where S.Element == UUID

	func deleteItems<S: Sequence>(ids: S) async throws where S.Element == UUID

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws
}

final class Database {

	lazy var backgroundContext: NSManagedObjectContext = {
		return container.viewContext
	}()

	// MARK: - DI by initialization

	let container: NSPersistentContainer

	// MARK: - Initialization

	init(container: NSPersistentContainer) {
		self.container = container
	}
}

// MARK: - DataManager
extension Database: DataManager {

	func insertItem(id: UUID, properties: Item.Properties, to list: UUID?) async throws {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let newEntity = ItemEntity.createObject(in: backgroundContext, with: properties)

			if let list {

				let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
				request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [list])
				request.fetchLimit = 1

				let listEntity = try backgroundContext.fetch(request).first
				newEntity.list = listEntity
			}

			try backgroundContext.save()
		}
	}

	func updateItems<S, T>(ids: S, tags: T) async throws where S : Sequence, T : Sequence, S.Element == UUID, T.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			let tagEntities = try { [weak self] in
				let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [tags])

				return try self?.backgroundContext.fetch(request)
			}()

			let relationship: NSSet? = {
				guard let tagEntities, !tagEntities.isEmpty else {
					return nil
				}
				return NSSet(array: tagEntities)
			}()

			for itemEntity in itemEntities ?? [] {
				itemEntity.tags = relationship
			}

			try backgroundContext.save()
		}
	}

	func updateItems<S>(ids: S, list: UUID?) async throws where S : Sequence, S.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			let listEntity: ListEntity? = try { [weak self] in
				guard let list else {
					return nil
				}
				let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
				request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [list])
				return try self?.backgroundContext.fetch(request).first
			}()

			for itemEntity in itemEntities ?? [] {
				itemEntity.list = listEntity
			}

			try backgroundContext.save()
		}
	}

	func updateItems<S>(ids: S, insert options: ItemOptions) async throws where S : Sequence, S.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			for itemEntity in itemEntities ?? [] {
				let oldOptions = ItemOptions(rawValue: itemEntity.rawOptions)
				itemEntity.rawOptions = oldOptions.union(options).rawValue
			}

			try backgroundContext.save()
		}
	}

	func updateItems<S>(ids: S, remove options: ItemOptions) async throws where S : Sequence, S.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			for itemEntity in itemEntities ?? [] {
				let oldOptions = ItemOptions(rawValue: itemEntity.rawOptions)
				itemEntity.rawOptions = oldOptions.subtracting(options).rawValue
			}

			try backgroundContext.save()
		}
	}

	func updateItems<S>(ids: S, text: String) async throws where S : Sequence, S.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			for itemEntity in itemEntities ?? [] {
				itemEntity.text = text
			}

			try backgroundContext.save()
		}
	}

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			var entities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = nil
				request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true)]

				return try self?.backgroundContext.fetch(request)
			}()

			guard var entities else {
				return
			}

			try move(with: id, to: destination, in: &entities)

			for (index, entity) in entities.enumerated() {
				entity.offset = Int64(index)
			}
			try backgroundContext.save()
		}
	}

	func deleteItems<S>(ids: S) async throws where S : Sequence, S.Element == UUID {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}

			let itemEntities = try { [weak self] in
				let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
				request.predicate = NSPredicate(format: "ANY uuid IN %@", argumentArray: [ids])

				return try self?.backgroundContext.fetch(request)
			}()

			for itemEntity in itemEntities ?? [] {
				backgroundContext.delete(itemEntity)
			}

			try backgroundContext.save()
		}
	}

	func insertObject<O>(type: O.Type, properties: O.Properties, relationships: O.Relationships?) async throws where O : ManagedObject {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			O.createObject(in: backgroundContext, with: properties, relationships: relationships)
			try backgroundContext.save()
		}
	}

	func updateObjects<R>(request: R, properties: R.Entity.Properties, relationships: R.Entity.Relationships?) async throws where R : ObjectsRequest {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			let objects = try backgroundContext.fetch(request.value)
			for object in objects {
				object.update(with: properties, relationships: relationships)
			}
			try backgroundContext.save()
		}
	}

	func deleteObjects<R>(request: R) async throws where R : ObjectsRequest {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			let objects = try backgroundContext.fetch(request.value)
			for object in objects {
				backgroundContext.delete(object)
			}
			try backgroundContext.save()
		}
	}
}

private extension Database {

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
