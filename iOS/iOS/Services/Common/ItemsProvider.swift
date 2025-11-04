//
//  ItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

final class ItemsObserver: NSObject {

	private let base: DataObserver<[Item]>

	// MARK: - Core Data

	let request: ItemsRequest

	private let container: any PersistentContainer

	lazy private var fetchedResultController: NSFetchedResultsController<ItemEntity> = {

		let fetchRequest = ItemEntity.fetchRequest()
		fetchRequest.sortDescriptors =
		[
			NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
			NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
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

	init(container: any PersistentContainer, request: ItemsRequest) {
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
extension ItemsObserver: NSFetchedResultsControllerDelegate {

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		guard let entities = controller.fetchedObjects as? [ItemEntity] else {
			return
		}
		let items = entities.map { $0.model }
		base.sendData(items)
	}
}

// MARK: - Computed Properties
extension ItemsObserver {

	func stream() -> AsyncStream<[Item]> {
		base.stream
	}

	func item(for id: UUID) -> Item? {
		base.lastValue().first {
			$0.id == id
		}
	}
}

extension ItemsRequest {

	var predicate: NSPredicate? {
		guard let id = list else {
			return nil
		}
		return NSPredicate(format: "list.uuid == %@", argumentArray: [id])
	}
}
