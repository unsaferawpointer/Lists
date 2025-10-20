//
//  ItemsConverter.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import CoreData

final class ItemsConverter { }

// MARK: - Converter
extension ItemsConverter: Converter {

	typealias T = ItemEntity

	typealias U = Item

	func convert(input: [ItemEntity]) -> [Item] {
		return input.compactMap { entity in
			guard let uuid = entity.uuid else {
				return nil
			}
			return Item(uuid: uuid, title: entity.text ?? "Unknown title", isStrikethrough: entity.isStrikethrough)
		}
	}

	func newEntity(for item: Item, in context: NSManagedObjectContext) -> ItemEntity {
		let entity = ItemEntity(context: context)
		entity.uuid = item.id
		entity.text = item.title
		entity.creationDate = .now
		return entity
	}
}
