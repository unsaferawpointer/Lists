//
//  Storage.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation
import CoreData

protocol StorageProtocol {
	func fetchItems(in list: UUID?) async throws -> [Item]
	func fetchItem(with id: UUID) async throws -> Item?
	func addItem(_ item: Item) async throws
	func setText(_ text: String, for item: UUID) async throws
	func deleteItems(with ids: [UUID]) async throws

	func addList(with name: String) async throws
	func setListName(_ name: String, for id: UUID) async throws
	func deleteList(with id: UUID) async throws

	func fecthLists() async throws -> [List]
}


final class Storage {

	// MARK: - Data

	private var lists: [List] = [.init(uuid: .init(), name: UUID().uuidString)]

	private var items: [Item] = Array(repeating: .init(uuid: UUID(), title: "Defailt Item"), count: 240)

	// MARK: - Stored Properties

	private let persistentContainer: NSPersistentContainer

	// MARK: - Initialization

	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
}

// MARK: - Computed Properties
private extension Storage {

	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
}

// MARK: - StorageProtocol
extension Storage: StorageProtocol {

	func fetchItems(in list: UUID?) async throws -> [Item] {
		return items
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return items.first(where: { $0.id == id })
	}

	func addItem(_ item: Item) async throws {
		items.append(item)
	}

	func setText(_ text: String, for item: UUID) async throws {
		guard let index = items.firstIndex(where: { $0.id == item }) else {
			return
		}
		items[index].title = text
	}

	func deleteItems(with ids: [UUID]) async throws {
		items.removeAll {
			ids.contains($0.id)
		}
	}

	func fecthLists() async throws -> [List] {
		return lists
	}

	func addList(with name: String) async throws {
		let newList = ListEntity(context: context)
		newList.name = name
		do {
			try context.save()
		} catch {
			
		}
	}

	func setListName(_ name: String, for id: UUID) async throws {
		guard let list = fetchList(with: id) else {
			return
		}
		do {
			list.name = name
			try context.save()
		}
	}

	func deleteList(with id: UUID) async throws {
		guard let list = fetchList(with: id) else {
			return
		}

		do {
			context.delete(list)
			try context.save()
		}
	}
}

// MARK: - Helpers
private extension Storage {

	func fetchList(with id: UUID) -> ListEntity? {

		let request = ListEntity.fetchRequest()
		request.predicate = NSPredicate(format: "uuid == %@", argumentArray: [id])
		request.fetchLimit = 1

		let lists = try? context.fetch(request)
		return lists?.first
	}
}
