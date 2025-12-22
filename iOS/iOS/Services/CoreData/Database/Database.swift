//
//  Database.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

@preconcurrency import CoreData

protocol DataManager {

	func insertObject<O: ManagedObject>(type: O.Type, properties: O.Properties, relationships: O.Relationships?) async throws

	func updateObjects<R: ObjectsRequest>(request: R, properties: R.Entity.Properties, relationships: R.Entity.Relationships?) async throws

	func deleteObjects<R: ObjectsRequest>(request: R) async throws
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

struct Relationship<T: ManagedObject> {

	var entity: T

	var keyPath: KeyPath<T, NSSet>
}
