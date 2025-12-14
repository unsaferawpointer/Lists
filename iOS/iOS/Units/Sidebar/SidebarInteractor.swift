//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarInteractorProtocol: AnyObject {
	func fetchLists() async throws
	func fetchFilters() async throws
	func addList(with properties: List.Properties) async throws
	func addFilter(with properties: Filter.Properties) async throws
	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func deleteList(with id: UUID)
	func updateList(with id: UUID, properties: List.Properties) async throws
	func list(for id: UUID) async throws -> List?
}

final class SidebarInteractor {

	// MARK: - DI by Property

	weak var presenter: SidebarPresenterProtocol?

	// MARK: - DI by initialization

	private let storage: StorageProtocol

	private let listProvider: ModelsProvider<List>

	private let filtersProvider: ModelsProvider<Filter>

	// MARK: - Initialization

	init(storage: StorageProtocol, listProvider: ModelsProvider<List>, filtersProvider: ModelsProvider<Filter>) {
		self.storage = storage
		self.listProvider = listProvider
		self.filtersProvider = filtersProvider
		Task { @MainActor in
			for await change in await listProvider.stream() {
				presenter?.present(lists: change)
			}
		}

		Task { @MainActor in
			for await change in await filtersProvider.stream() {
				presenter?.present(filters: change)
			}
		}
	}
}

// MARK: - SidebarInteractorProtocol
extension SidebarInteractor: SidebarInteractorProtocol {

	func deleteList(with id: UUID) {
		Task { @MainActor in
			try? await storage.deleteList(with: id)
		}
	}

	func updateList(with id: UUID, properties: List.Properties) async throws {
		try? await storage.updateList(with: id, properties: properties)
	}

	func addList(with properties: List.Properties) async throws {
		let newList = List(uuid: UUID(), properties: properties)
		try? await storage.addList(newList)
	}

	func addFilter(with properties: Filter.Properties) async throws {
		let newFilter = Filter(uuid: UUID(), properties: properties)
		try? await storage.addFilter(newFilter)
	}

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try? await storage.moveList(with: id, to: destination)
	}

	func list(for id: UUID) async throws -> List? {
		await listProvider.item(for: id)
	}

	func fetchLists() async throws {
		try await listProvider.fetchData()
	}

	func fetchFilters() async throws {
		try await filtersProvider.fetchData()
	}
}
