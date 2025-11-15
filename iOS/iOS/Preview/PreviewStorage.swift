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

	func setTags(items ids: [UUID], tags: Set<UUID>) async throws { }

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) async throws { }

	func moveItems(with ids: [UUID], to tag: UUID?) async throws { }

	func updateTag(with id: UUID, properties: Tag.Properties) async throws { }

	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>) async throws { }

	func updateItems(with ids: [UUID], change: ItemChange) async throws { }

	func addTag(_ tag: Tag) async throws { }
	

	func modificate<E>(type: E.Type, with ids: [UUID], modification: (E) -> Void) async throws where E : NSManagedObject { }
	func addItem(_ item: Item, to tag: UUID?) async throws { }

	func setTagName(_ name: String, for id: UUID) async throws { }

	func deleteTag(with id: UUID) async throws { }

	func addTag(with name: String) async throws { }

	func addItem(_ item: Item) async throws { }

	func setText(_ text: String, for item: UUID) async throws { }

	func deleteItems(with ids: [UUID]) async throws { }

	func fetchItems(in tag: UUID?) async throws -> [Item] {
		[]
	}

	func fetchItem(with id: UUID) async throws -> Item? {
		return nil
	}

	func fecthTags() async throws -> [Tag] { [ ] }
}
