//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarInteractorProtocol: AnyObject {
	func fetchLists() async throws -> [List]
	func addList(with name: String) async throws
	func deleteList(with id: UUID)
	func setListName(_ name: String, for id: UUID) async throws
	func list(for id: UUID) async throws -> List?
}

final class SidebarInteractor {

	// MARK: - DI by Property

	weak var presenter: SidebarPresenterProtocol?

	// MARK: - DI by initialization

	private let storage: StorageProtocol

	private let provider: DataProvider<List, ListEntity>

	// MARK: - Initialization

	init(storage: StorageProtocol, provider: DataProvider<List, ListEntity>) {
		self.storage = storage
		self.provider = provider
		Task { @MainActor in
			for await change in provider.contentChanges {
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

	func setListName(_ name: String, for id: UUID) async throws {
		let change: ListChange = .name(value: name)
		try? await storage.updateList(with: id, change: change)
	}

	func addList(with name: String) async throws {
		let newList = List(uuid: UUID(), name: name)
		try? await storage.addList(newList)
	}

	func list(for id: UUID) async throws -> List? {
		provider.firstItem(where: { $0.id == id} )
	}

	func fetchLists() async throws -> [List] {
		provider.fetch()
		return []
	}
}
