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
			return List(uuid: uuid, name: entity.name ?? "Undefeniend Name")
		}
	}

	func newEntity(for item: List, in context: NSManagedObjectContext) -> ListEntity {
		let entity = ListEntity(context: context)
		entity.uuid = item.id
		entity.name = item.name
		entity.creationDate = .now
		return entity
	}
}
