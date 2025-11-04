//
//  DataProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import CoreData

protocol EntityConvertable: NSManagedObject {

	associatedtype Model: ModelConvertable

	var model: Model { get }

	static func create(from model: Model, in context: NSManagedObjectContext) -> Self
}

protocol ModelConvertable {
	associatedtype Entity: EntityConvertable where Entity.Model == Self
}

final class DataProvider<Model: ModelConvertable>: Sendable {

	typealias Entity = Model.Entity

	// MARK: - Internal State

	private var continuation: AsyncStream<[Model]>.Continuation?

	var models: [Model] = [] {
		didSet {
			continuation?.yield(models)
		}
	}

	// MARK: - Public Properties

	lazy var contentChanges: AsyncStream<[Model]> = {
		AsyncStream { continuation in
			self.continuation = continuation
			continuation.onTermination = { [weak self] _ in
				self?.continuation = nil
			}
		}
	}()

	let coreDataProvider: CoreDataProvider<Entity>

	// MARK: - Initialization

	init(coreDataProvider: CoreDataProvider<Entity>) {
		self.coreDataProvider = coreDataProvider
		coreDataProvider.handler = { [weak self] entities in
			self?.models = entities.map(\.model)
		}
	}

	func firstItem(where condition: (Model) -> Bool) -> Model? {
		return models.first(where: condition)
	}

	func fetch() {
		coreDataProvider.fetch()
	}
}
