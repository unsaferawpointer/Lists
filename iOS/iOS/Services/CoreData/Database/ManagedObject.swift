//
//  ManagedObject.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

import CoreData

protocol ManagedObject: NSManagedObject, Identifiable {

	associatedtype Properties

	static func createObject(in context: NSManagedObjectContext, with properties: Properties)

	func update(with properties: Properties)

	var object: Object<Properties> { get }
}

struct Object<Properties>: Identifiable {

	let id: UUID

	let properties: Properties

	// MARK: - Initialization

	init(id: ID, properties: Properties) {
		self.id = id
		self.properties = properties
	}
}
