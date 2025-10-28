//
//  CoreDataProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation
import CoreData

final class CoreDataProvider<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

	// MARK: - Stored Properties

	private let persistentContainer: NSPersistentContainer

	private let sortDescriptors: [NSSortDescriptor]

	private let predicate: NSPredicate?

	private let fetchLimit: Int?

	lazy private var fetchedResultController: NSFetchedResultsController<T> = {

		let request = NSFetchRequest<T>(entityName: String(describing: T.self))
		request.sortDescriptors = sortDescriptors
		request.predicate = predicate
		if let fetchLimit {
			request.fetchLimit = fetchLimit
		}

		let controller = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: persistentContainer.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		controller.delegate = self

		return controller
	}()

	// MARK: - Public Interface

	var handler: (([T]) -> Void)?

	func fetch() {
		do {
			try fetchedResultController.performFetch()
			handler?(fetchedResultController.fetchedObjects ?? [])
		} catch {
			handler?([])
		}
	}

	// MARK: - Initialization

	init(
		persistentContainer: NSPersistentContainer,
		sortDescriptors: [NSSortDescriptor],
		predicate: NSPredicate?,
		fetchLimit: Int? = nil
	) {
		self.persistentContainer = persistentContainer
		self.sortDescriptors = sortDescriptors
		self.predicate = predicate
		self.fetchLimit = fetchLimit
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		guard let entities = controller.fetchedObjects as? [T] else {
			return
		}
		handler?(entities)
	}
}
