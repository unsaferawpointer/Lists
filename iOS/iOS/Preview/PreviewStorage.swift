//
//  PreviewStorage.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation
import CoreData

final class PreviewStorage { }

// MARK: - StorageProtocol
extension PreviewStorage: StorageProtocol {

	func updateTag(with id: UUID, properties: Tag.Properties) async throws { }

	func deleteTags(with ids: [UUID]) async throws { }

	func addTag(_ tag: Tag) async throws { }

	func setTags(_ tags: Set<UUID>, for items: [UUID]) async throws { }

	func setList(items ids: [UUID], list: UUID?) async throws { }

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>) async throws { }

	func moveItems(with ids: [UUID], to list: UUID?) async throws { }

	func updateList(with id: UUID, properties: List.Properties) async throws { }

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws { }

	func updateItems(with ids: [UUID], change: ItemChange) async throws { }

	func addList(_ list: List) async throws { }
	

	func modificate<E>(type: E.Type, with ids: [UUID], modification: (E) -> Void) async throws where E : NSManagedObject { }
	func addItem(_ item: Item, to list: UUID?) async throws { }

	func setListName(_ name: String, for id: UUID) async throws { }

	func deleteList(with id: UUID) async throws { }

	func addList(with name: String) async throws { }

	func addItem(_ item: Item) async throws { }

	func setText(_ text: String, for item: UUID) async throws { }

	func deleteItems(with ids: [UUID]) async throws { }

	func fetchItems(in list: UUID?) async throws -> [Item] {
		[]
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return nil
	}

	func fecthLists() async throws -> [List] { [ ] }
}
