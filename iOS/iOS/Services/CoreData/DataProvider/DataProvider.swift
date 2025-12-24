//
//  DataProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.12.2025.
//

@preconcurrency import CoreData

protocol DataProviderProtocol {

	func fetchObjects<R: ObjectsRequest>(with request: R) async throws -> [Object<R.Entity.Properties, R.Entity.Relationships>]

	var stream: NotificationCenter.Notifications { get }
}

final class DataProvider {

	lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = container.viewContext
		context.automaticallyMergesChangesFromParent = true
		return context
	}()

	// MARK: - DI by initialization

	let container: NSPersistentContainer

	lazy var stream: NotificationCenter.Notifications = {
		let name: NSNotification.Name = .NSManagedObjectContextDidSave
		return NotificationCenter.default.notifications(named: name)
	}()

	// MARK: - Initialization

	init(container: NSPersistentContainer) {
		self.container = container
	}
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {

	func fetchObjects<R: ObjectsRequest>(with request: R) async throws -> [Object<R.Entity.Properties, R.Entity.Relationships>] {
		return try await withCheckedThrowingContinuation { continuation in
			backgroundContext.performAndWait {
				do {
					let entities = try backgroundContext.fetch(request.value)
					let objects = entities.map(\.object)
					continuation.resume(returning: objects)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
}
