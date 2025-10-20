//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarInteractorProtocol: AnyObject {
	func fetchLists() async throws -> [List]
	func addList(with name: String)
	func deleteList(with id: UUID)
	func setListName(_ name: String, for id: UUID)
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

	func setListName(_ name: String, for id: UUID) {
		Task { @MainActor in
			try? await storage.setListName(name, for: id)
		}
	}

	func addList(with name: String) {
		Task { @MainActor in
			try? await storage.addList(with: name)
		}
	}

	func list(for id: UUID) async throws -> List? {
		provider.firstItem(where: { $0.id == id} )
	}

	func fetchLists() async throws -> [List] {
		provider.fetch()
		return []
	}
}
