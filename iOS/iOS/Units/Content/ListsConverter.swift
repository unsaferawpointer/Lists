//
//  ListsConverter.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.10.2025.
//

import CoreData

final class ListsConverter { }

// MARK: - Converter
extension ListsConverter: Converter {

	typealias T = ListEntity

	typealias U = List

	func convert(input: [ListEntity]) -> [List] {
		return input.compactMap { entity in
			guard let uuid = entity.uuid else {
				return nil
			}
			let properties = List.Properties(name: entity.name ?? "Undefeniend Name", icon: entity.icon)
			return List(uuid: uuid, properties: properties)
		}
	}

	func newEntity(for item: List, in context: NSManagedObjectContext) -> ListEntity {
		let entity = ListEntity(context: context)
		entity.uuid = item.id
		entity.name = item.name
		entity.creationDate = .now
		entity.icon = item.properties.icon
		return entity
	}
}
