//
//  ItemsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import Foundation
import CoreData

final class ItemsObserver: NSObject {

	// MARK: - Internal State

	private let base: DataObserver<[Item]>

	// MARK: - Core Data

	private var controller: NSFetchedResultsController<ItemEntity>?

	// MARK: - Initialization

	init(container: any PersistentContainer, request: ItemsRequest) {
		self.base = .init(initialData: [])
		super.init()

		self.controller = buildController(with: container, request: request)
	}

	func fetchData() {
		guard let controller else {
			return
		}
		do {
			try controller.performFetch()
			let entities = controller.fetchedObjects ?? []
			let items = entities.map { $0.model }
			Task {
				await base.sendData(items)
			}
		} catch {
			Task {
				await base.sendData([])
			}
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
		Task {
			await base.sendData(items)
		}
	}
}

// MARK: - Helpers
private extension ItemsObserver {

	func buildController(with container: any PersistentContainer, request: ItemsRequest) -> NSFetchedResultsController<ItemEntity> {
		let fetchRequest = ItemEntity.fetchRequest()
		fetchRequest.sortDescriptors =
		[
			NSSortDescriptor(keyPath: \ItemEntity.offset, ascending: true),
			NSSortDescriptor(keyPath: \ItemEntity.creationDate, ascending: true)
		]
		fetchRequest.predicate = request.predicate
		if let fetchLimit = request.fetchLimit {
			fetchRequest.fetchLimit = fetchLimit
		}

		let context = container.mainContext
		let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context)
		controller.delegate = self

		return controller
	}
}

// MARK: - Computed Properties
extension ItemsObserver {

	func stream() async -> AsyncStream<[Item]> {
		await base.stream
	}

	func item(for id: UUID) async -> Item? {
		await base.lastValue().first {
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
