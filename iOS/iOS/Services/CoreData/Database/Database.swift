//
//  Database.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

@preconcurrency import CoreData

protocol DataProvider<T> {

	associatedtype T: ManagedObject

	func fetchObjects(with request: NSFetchRequest<T>) async throws -> [T]
}

protocol DataManager<T> {

	associatedtype T: ManagedObject

	func insertObject(properties: T.Properties) async throws

	func updateObjects(request: NSFetchRequest<T>, properties: T.Properties) async throws

	func deleteObjects(request: NSFetchRequest<T>) async throws
}

final class Database<T: ManagedObject> {

	lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		return context
	}()

	// MARK: - DI by initialization

	let container: NSPersistentContainer

	// MARK: - Initialization

	init(container: NSPersistentContainer) {
		self.container = container

		configureNotifications()
	}
}

// MARK: - Configure
private extension Database {

	func configureNotifications() {
		let name: NSNotification.Name = .NSManagedObjectContextDidSave
		NotificationCenter.default.addObserver(forName: name, object: backgroundContext, queue: .main) { [weak self] notification in
			self?.handleNotification(notification)
		}
	}

	func handleNotification(_ notification: Notification) {

	}
}

// MARK: - DataProvider
extension Database: DataProvider {

	func fetchObjects(with request: NSFetchRequest<T>) async throws -> [T] {
		return try await withCheckedThrowingContinuation { continuation in
			backgroundContext.performAndWait {
				do {
					let objects = try backgroundContext.fetch(request)
					continuation.resume(returning: objects)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
}

// MARK: - DataManager
extension Database: DataManager {

	func insertObject(properties: T.Properties) async throws {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			T.createObject(in: backgroundContext, with: properties)
			try backgroundContext.save()
		}
	}
	
	func updateObjects(request: NSFetchRequest<T>, properties: T.Properties) async throws {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			let objects = try backgroundContext.fetch(request)
			for object in objects {
				object.update(with: properties)
			}
			try backgroundContext.save()
		}
	}
	
	func deleteObjects(request: NSFetchRequest<T>) async throws {
		try await backgroundContext.perform { [weak self] in
			guard let self else {
				return
			}
			let objects = try backgroundContext.fetch(request)
			for object in objects {
				backgroundContext.delete(object)
			}
			try backgroundContext.save()
		}
	}
}
