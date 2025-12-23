//
//  FilteredContent + Interactor.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.12.2025.
//

import Foundation
import CoreData

extension FilteredContent {

	final class Interactor {

		// MARK: - DI by Property

		weak var presenter: ContentPresenterProtocol?

		// MARK: - DI by initialization

		private let identifier: UUID

		private let filterProvider: DataProvider<FilterEntity>

		private let itemsProvider: DataProvider<ItemEntity>

		// MARK: - Initialization

		init(identifier: UUID, filterProvider: DataProvider<FilterEntity>, itemsProvider: DataProvider<ItemEntity>) {
			self.identifier = identifier
			self.filterProvider = filterProvider
			self.itemsProvider = itemsProvider

			Task { [weak self] in
				for await _ in filterProvider.stream {
					self?.fetchData()
				}
			}
			Task { [weak self] in
				for await _ in itemsProvider.stream {
					self?.fetchData()
				}
			}
		}
	}
}

// MARK: - ContentInteractorProtocol
extension FilteredContent.Interactor: ContentInteractorProtocol {

	func fetchItems() async throws {
		Task {
			let filterRequest = FilterRequestV2(identifier: identifier)
			guard let filters = try? await filterProvider.fetchObjects(with: filterRequest), let filter = filters.first else {
				return
			}
			let itemsRequest = ItemsRequestV2(tags: filter.relationships?.tags?.map(\.self), itemOptions: filter.properties.itemOptions)
			guard let items = try? await itemsProvider.fetchObjects(with: itemsRequest) else {
				return
			}
			await MainActor.run { [weak self] in
				self?.presenter?.present(items: items.map( { Item(uuid: $0.id, properties: $0.properties, tags: [])}))
			}
		}
	}
	
	func addItem(with properties: Item.Properties) async throws {

	}
	
	func item(for id: UUID) async throws -> Item? {
		return nil
	}
	
	func setText(_ text: String, for item: UUID) async throws {

	}
	
	func strikeThroughItems(with ids: [UUID], flag: Bool) async throws {

	}
	
	func deleteItems(with ids: [UUID]) async throws {

	}
	
	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws {

	}
	
	func setList(items ids: [UUID], list: UUID?) async throws {

	}
	
	func setTags(_ tags: Set<UUID>, for items: [UUID]) async throws {

	}
}

// MARK: - Helpers
private extension FilteredContent.Interactor {

	func fetchData() {
		Task {
			let filterRequest = FilterRequestV2(identifier: identifier)
			guard let filters = try? await filterProvider.fetchObjects(with: filterRequest), let filter = filters.first else {
				return
			}
			let itemsRequest = ItemsRequestV2(tags: filter.relationships?.tags?.map(\.self), itemOptions: filter.properties.itemOptions)
			guard let items = try? await itemsProvider.fetchObjects(with: itemsRequest) else {
				return
			}
			await MainActor.run { [weak self] in
				self?.presenter?.present(items: items.map( { Item(uuid: $0.id, properties: $0.properties, tags: [])}))
			}
		}
	}
}
