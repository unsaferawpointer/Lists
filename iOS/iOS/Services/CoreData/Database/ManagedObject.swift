//
//  ManagedObject.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

import CoreData

protocol ManagedObject: NSManagedObject, Identifiable {

	associatedtype Properties

	associatedtype Relationships

	static func createObject(in context: NSManagedObjectContext, with properties: Properties, relationships: Relationships?)

	static func createObject(in context: NSManagedObjectContext, with properties: Properties) -> Self

	func update(with properties: Properties, relationships: Relationships?)

	func update(with properties: Properties)

	var properties: Properties { get }

	var object: Object<Properties, Relationships> { get }
}
