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
		return input.compactMap { entity -> Item? in
			guard let uuid = entity.uuid else {
				return nil
			}
			let properties = Item.Properties(title: entity.text ?? "Unknown title", isStrikethrough: entity.isStrikethrough)
			return Item(uuid: uuid, properties: properties)
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
