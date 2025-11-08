//
//  Convertable.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import CoreData

protocol EntityConvertable: NSManagedObject, Identifiable {

	associatedtype Model: ModelConvertable

	var model: Model { get }

	static func create(from model: Model, in context: NSManagedObjectContext) -> Self
}

protocol ModelConvertable {
	associatedtype Entity: EntityConvertable where Entity.Model == Self
}
