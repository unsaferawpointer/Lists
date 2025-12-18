//
//  ManagedObject.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.12.2025.
//

import CoreData

protocol ManagedObject: NSManagedObject {

	associatedtype Properties

	static func createObject(in context: NSManagedObjectContext, with properties: Properties)

	func update(with properties: Properties)
}
