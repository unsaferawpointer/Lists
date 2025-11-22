//
//  ModelsProvider.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import Foundation

final class ModelsProvider<Model: ModelConvertable> {

	// MARK: - Internal State

	private let base: DataObserver<[Model]>

	// MARK: - Core Data

	private var entitiesProvder: EntitiesProvider<Model>

	// MARK: - Initialization

	init<R: RequestRepresentable>(container: any PersistentContainer, request: R) where R.Entity == Model.Entity {
		self.base = .init(initialData: [])
		self.entitiesProvder = EntitiesProvider(container: container, request: request)
		self.entitiesProvder.delegate = self
	}

	func fetchData() async throws {
		Task { @MainActor in
			try entitiesProvder.fetchData()
		}
	}
}

// MARK: - EntitesProviderDelegate
extension ModelsProvider: EntitesProviderDelegate {

	func providerDidChangeContent(models: [Model]) {
		Task {
			await base.sendData(models)
		}
	}
}

// MARK: - Computed Properties
extension ModelsProvider where Model == Item {

	func stream() async -> AsyncStream<[Model]> {
		await base.stream
	}

	func item(for id: UUID) async -> Model? {
		await base.lastValue().first {
			$0.id == id
		}
	}

	func items() async -> [Model] {
		await base.lastValue()
	}
}

extension ModelsProvider where Model == List {

	func stream() async -> AsyncStream<[Model]> {
		await base.stream
	}

	func item(for id: UUID) async -> Model? {
		await base.lastValue().first {
			$0.id == id
		}
	}
}
