//
//  Storage.swift
//  Lists
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import SwiftData
import SwiftUI

protocol StorageProtocol {

	static func listsQuery() -> Query<ListEntity, [ListEntity]>
	static func itemsQuery(in list: ListEntity?) -> Query<ItemEntity, [ItemEntity]>

	static func deleteItems(_ ids: [PersistentIdentifier], in context: ModelContext)
	static func deleteLists(_ ids: [PersistentIdentifier], in context: ModelContext)
}

final class Storage { }

// MARK: - StorageProtocol
extension Storage: StorageProtocol {

	static func listsQuery() -> Query<ListEntity, [ListEntity]> {
		let predicate: Predicate<ListEntity> = #Predicate{ list in
			list.isHidden == false
		}

		let sorting = [SortDescriptor(\ListEntity.offset), SortDescriptor(\ListEntity.timestamp)]

		return Query(filter: predicate, sort: sorting, animation: .default)
	}

	static func itemsQuery(in list: ListEntity?) -> Query<ItemEntity, [ItemEntity]> {
		let predicate: Predicate<ItemEntity>? = {
			if let list {
				let id = list.id
				return #Predicate<ItemEntity> { item in
					item.list?.id == id
				}
			} else {
				return nil
			}
		}()

		let sorting =
		[
			SortDescriptor(\ItemEntity.strikeThrough),
			SortDescriptor(\ItemEntity.timestamp)
		]
		return Query(filter: predicate, sort: sorting, animation: .default)
	}

	static func deleteItems(_ ids: [PersistentIdentifier], in context: ModelContext) {
		let items = ids.compactMap {
			context.model(for: $0) as? ItemEntity
		}.filter {
			$0.isDeleted == false
		}
		items.forEach { context.delete($0) }
	}

	static func deleteLists(_ ids: [PersistentIdentifier], in context: ModelContext) {
		let items = ids.compactMap {
			context.model(for: $0) as? ListEntity
		}.filter {
			$0.isDeleted == false
		}
		items.forEach { context.delete($0) }
	}
}
