//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarInteractorProtocol: AnyObject {
	func fetchLists() async throws -> [List]
	func addList(with properties: List.Properties) async throws
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

	private let provider: ListsObserver

	// MARK: - Initialization

	init(storage: StorageProtocol, provider: ListsObserver) {
		self.storage = storage
		self.provider = provider
		Task { @MainActor in
			for await change in provider.stream() {
				presenter?.present(lists: change)
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

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try? await storage.moveList(with: id, to: destination)
	}

	func list(for id: UUID) async throws -> List? {
		provider.item(for: id)
	}

	func fetchLists() async throws -> [List] {
		provider.fetchData()
		return []
	}
}
