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

	init(container: any PersistentContainer, request: any RequestRepresentable) {
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
