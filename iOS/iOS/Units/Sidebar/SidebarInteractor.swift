//
//  SidebarInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarInteractorProtocol: AnyObject {
	func fetchTags() async throws
	func addTag(with properties: Tag.Properties) async throws
	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) async throws
	func deleteTag(with id: UUID)
	func updateTag(with id: UUID, properties: Tag.Properties) async throws
	func tag(for id: UUID) async throws -> Tag?
}

final class SidebarInteractor {

	// MARK: - DI by Property

	weak var presenter: SidebarPresenterProtocol?

	// MARK: - DI by initialization

	private let storage: StorageProtocol

	private let provider: ModelsProvider<Tag>

	// MARK: - Initialization

	init(storage: StorageProtocol, provider: ModelsProvider<Tag>) {
		self.storage = storage
		self.provider = provider
		Task { @MainActor in
			for await change in await provider.stream() {
				presenter?.present(tags: change)
			}
		}
	}
}

// MARK: - SidebarInteractorProtocol
extension SidebarInteractor: SidebarInteractorProtocol {

	func deleteTag(with id: UUID) {
		Task { @MainActor in
			try? await storage.deleteTag(with: id)
		}
	}

	func updateTag(with id: UUID, properties: Tag.Properties) async throws {
		try? await storage.updateTag(with: id, properties: properties)
	}

	func addTag(with properties: Tag.Properties) async throws {
		let newTag = Tag(uuid: UUID(), properties: properties)
		try? await storage.addTag(newTag)
	}

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) async throws {
		try? await storage.moveTag(with: id, to: destination)
	}

	func tag(for id: UUID) async throws -> Tag? {
		await provider.item(for: id)
	}

	func fetchTags() async throws {
		try await provider.fetchData()
	}
}
