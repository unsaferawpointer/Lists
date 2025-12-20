//
//  DataProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.12.2025.
//

@preconcurrency import CoreData

protocol DataProviderProtocol<T> {

	associatedtype T: ManagedObject

	func fetchObjects(with request: NSFetchRequest<T>) async throws -> [T]
}

final class DataProvider<T: ManagedObject> {

	lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = container.viewContext
		return context
	}()

	// MARK: - DI by initialization

	let container: NSPersistentContainer

	lazy var stream: NotificationCenter.Notifications = {
		let name: NSNotification.Name = .NSManagedObjectContextDidSave
		return NotificationCenter.default.notifications(named: name, object: backgroundContext)
	}()

	// MARK: - Initialization

	init(container: NSPersistentContainer) {
		self.container = container
	}
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {

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
