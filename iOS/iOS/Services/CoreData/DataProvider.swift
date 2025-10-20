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
			let models = converter.convert(input: entities)
			self?.contentChangeContinuation?.yield(models)
		}
	}

	func fetch() {
		coreDataProvider.fetch()
	}
}
