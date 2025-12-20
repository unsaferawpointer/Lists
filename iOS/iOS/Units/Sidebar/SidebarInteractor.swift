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
	func addList(with properties: List.Properties) throws
	func addFilter(with properties: Filter.Properties) throws
	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func deleteList(with id: UUID) throws
	func deleteFilter(with id: UUID) throws
	func updateList(with id: UUID, properties: List.Properties) throws
	func updateFilter(id: UUID, properties: Filter.Properties, andTags tags: Set<UUID>) throws
	func list(for id: UUID) throws -> List?
}

@MainActor
final class SidebarInteractor {

	// MARK: - DI by Property

	weak var presenter: SidebarPresenterProtocol?

	// MARK: - DI by initialization

	private let database: any DataManager

	private let providers: Providers

	// MARK: - Initialization

	init(database: any DataManager, providers: Providers) {
		self.database = database
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

	func deleteList(with id: UUID) throws {
		let request = ListRequest(identifier: id)
		Task {
			try await database.deleteObjects(request: request)
		}
	}

	func deleteFilter(with id: UUID) throws {
		let request = FilterRequestV2(identifier: id)
		Task {
			try await database.deleteObjects(request: request)
		}
	}

	func updateList(with id: UUID, properties: List.Properties) throws {
		Task {
			let request = ListRequest(identifier: id)
			try await database.updateObjects(request: request, properties: properties)
		}
	}

	func updateFilter(id: UUID, properties: Filter.Properties, andTags tags: Set<UUID>) throws {
		Task {
			let request = FilterRequestV2(identifier: id)
			try await database.updateObjects(request: request, properties: properties)
		}
	}

	func addList(with properties: List.Properties) throws {
		Task {
			try await database.insertObject(type: ListEntity.self, properties: properties)
		}
	}

	func addFilter(with properties: Filter.Properties) throws {
		Task {
			try await database.insertObject(type: FilterEntity.self, properties: properties)
		}
	}

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		fatalError()
	}

	func list(for id: UUID) throws -> List? {
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
			let filters = try await providers.filters.fetchObjects(with: FiltersRequestV2())
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
