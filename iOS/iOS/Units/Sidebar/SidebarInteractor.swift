//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

@MainActor
protocol SidebarInteractorProtocol: AnyObject {
	func fetchLists() throws
	func fetchFilters() throws
	func addList(with properties: List.Properties) async throws
	func addFilter(with properties: Filter.Properties) async throws
	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func deleteList(with id: UUID)
	func updateList(with id: UUID, properties: List.Properties) async throws
	func updateFilter(id: UUID, properties: Filter.Properties, andTags tags: Set<UUID>) async throws
	func list(for id: UUID) async throws -> List?
}

@MainActor
final class SidebarInteractor {

	// MARK: - DI by Property

	weak var presenter: SidebarPresenterProtocol?

	// MARK: - DI by initialization

	private let storage: StorageProtocol

	private let providers: Providers

	// MARK: - Initialization

	init(storage: StorageProtocol, providers: Providers) {
		self.storage = storage
		self.providers = providers

		Task { [weak self] in
			for await _ in providers.lists.stream {
				try self?.fetchLists()
			}
		}

		Task { [weak self] in
			for await _ in providers.filters.stream {
				try self?.fetchFilters()
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

	func updateFilter(id: UUID, properties: Filter.Properties, andTags tags: Set<UUID>) async throws {
		try? await storage.updateFilter(id: id, properties: properties, andTags: tags)
	}

	func addList(with properties: List.Properties) async throws {
		let newList = List(uuid: UUID(), properties: properties)
		try? await storage.addList(newList)
	}

	func addFilter(with properties: Filter.Properties) async throws {
		let newFilter = Filter(uuid: UUID(), properties: properties, tags: nil)
		try? await storage.addFilter(newFilter)
	}

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try? await storage.moveList(with: id, to: destination)
	}

	func list(for id: UUID) async throws -> List? {
		return nil
//		await listProvider.item(for: id)
	}

	func fetchLists() throws {
		Task {
			let lists = try await providers.lists.fetchObjects(with: ListsRequestV2())
			await MainActor.run { [weak self] in
				self?.presenter?.present(lists: lists)
			}
		}
	}

	func fetchFilters() throws {
		Task {
			let filters = try await providers.filters.fetchObjects(with: FilterRequestV2())
			await MainActor.run { [weak self] in
				self?.presenter?.present(filters: filters)
			}
		}
	}
}

// MARK: - Nested Data Structs
extension SidebarInteractor {

	struct Providers {
		let lists: any DataProviderProtocol<ListEntity>
		let filters: any DataProviderProtocol<FilterEntity>
	}
}
