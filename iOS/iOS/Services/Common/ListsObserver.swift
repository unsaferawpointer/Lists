//
//  ListsObserver.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

final class ListsObserver: NSObject {

	private let base: DataObserver<[List]>

	// MARK: - Core Data

	let request: ListsRequest

	private let container: any PersistentContainer

	lazy private var fetchedResultController: NSFetchedResultsController<ListEntity> = {

		let fetchRequest = ListEntity.fetchRequest()
		fetchRequest.sortDescriptors =
		[
			NSSortDescriptor(keyPath: \ListEntity.offset, ascending: true),
			NSSortDescriptor(keyPath: \ListEntity.creationDate, ascending: true)
		]
		fetchRequest.predicate = self.request.predicate
		if let fetchLimit = self.request.fetchLimit {
			fetchRequest.fetchLimit = fetchLimit
		}

		let context = container.mainContext
		let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context)
		controller.delegate = self

		return controller
	}()

	// MARK: - Initialization

	init(container: any PersistentContainer, request: ListsRequest) {
		self.base = .init(initialData: [])
		self.request = request
		self.container = container
	}

	func fetchData() {
		do {
			try fetchedResultController.performFetch()
			let entities = fetchedResultController.fetchedObjects ?? []
			let items = entities.map { $0.model }
			base.sendData(items)
		} catch {
			base.sendData([])
		}
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension ListsObserver: NSFetchedResultsControllerDelegate {

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		guard let entities = controller.fetchedObjects as? [ListEntity] else {
			return
		}
		let items = entities.map { $0.model }
		base.sendData(items)
	}
}

// MARK: - Computed Properties
extension ListsObserver {

	func stream() -> AsyncStream<[List]> {
		base.stream
	}

	func item(for id: UUID) -> List? {
		base.lastValue().first {
			$0.id == id
		}
	}
}

extension ListsRequest {

	var predicate: NSPredicate? {
		guard let id = uuid else {
			return nil
		}
		return NSPredicate(format: "uuid == %@", argumentArray: [id])
	}
}
