//
//  EntitiesProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import CoreData

protocol EntitesProviderDelegate<Model>: AnyObject {
	associatedtype Model: ModelConvertable
	func providerDidChangeContent(models: [Model])
}

@MainActor
final class EntitiesProvider<Model: ModelConvertable>: NSObject, NSFetchedResultsControllerDelegate {

	typealias Entity = Model.Entity

	weak var delegate: (any EntitesProviderDelegate<Model>)?

	// MARK: - Core Data

	private var controller: NSFetchedResultsController<Entity>?

	// MARK: - Initialization

	init<R: RequestRepresentable>(container: any PersistentContainer, request: R) where R.Entity == Model.Entity {
		super.init()

		self.controller = buildController(with: container, request: request)
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		guard let entities = controller.fetchedObjects as? [Entity] else {
			return
		}
		let models = entities.compactMap(\.model)
		delegate?.providerDidChangeContent(models: models)
	}
}

// MARK: - Public Interface
extension EntitiesProvider {

	func fetchData() throws {
		guard let controller else {
			return
		}
		do {
			try controller.performFetch()
			let entities = controller.fetchedObjects ?? []
			let models = entities.compactMap(\.model)
			delegate?.providerDidChangeContent(models: models)
		}
	}
}

// MARK: - Helpers
private extension EntitiesProvider {

	func buildController(with container: any PersistentContainer, request: any RequestRepresentable) -> NSFetchedResultsController<Entity> {
		let fetchRequest = Entity.fetchRequest() as! NSFetchRequest<Entity>
		fetchRequest.sortDescriptors = request.nsSortDescriptors
		fetchRequest.predicate = request.nsPredicate
		if let fetchLimit = request.fetchLimit {
			fetchRequest.fetchLimit = fetchLimit
		}

		let controller = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: container.mainContext
		)
		controller.delegate = self

		return controller
	}
}

