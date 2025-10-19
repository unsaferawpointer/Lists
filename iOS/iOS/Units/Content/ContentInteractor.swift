//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol ContentInteractorProtocol {
	func fetchItems() async throws -> [Item]
}

final class ContentInteractor {

	// MARK: - DI by Property

	weak var presenter: ContentPresenterProtocol?

	// MARK: - DI by initialization

	private let id: UUID?

	private let storage: StorageProtocol

	// MARK: - Initialization

	init(id: UUID?, storage: StorageProtocol) {
		self.id = id
		self.storage = storage
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchItems() async throws -> [Item] {
		return try await storage.fetchItems(in: id)
	}
}
