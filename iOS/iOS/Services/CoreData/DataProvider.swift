//
//  DataProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import CoreData

final class DataProvider<Model, Entity: NSManagedObject>: Sendable {

	// MARK: - Internal State

	private var contentChangeContinuation: AsyncStream<[Model]>.Continuation?

	var models: [Model] = [] {
		didSet {
			contentChangeContinuation?.yield(models)
		}
	}

	// MARK: - Public Properties

	lazy var contentChanges: AsyncStream<[Model]> = {
		AsyncStream { continuation in
			self.contentChangeContinuation = continuation
			continuation.onTermination = { [weak self] _ in
				self?.contentChangeContinuation = nil
			}
		}
	}()

	let converter: any Converter<Entity, Model>

	let coreDataProvider: CoreDataProvider<Entity>

	// MARK: - Initialization

	init(coreDataProvider: CoreDataProvider<Entity>, converter: any Converter<Entity, Model>) {
		self.coreDataProvider = coreDataProvider
		self.converter = converter

		coreDataProvider.handler = { [weak self] entities in
			self?.models = converter.convert(input: entities)
		}
	}

	func firstItem(where condition: (Model) -> Bool) -> Model? {
		return models.first(where: condition)
	}

	func fetch() {
		coreDataProvider.fetch()
	}
}
