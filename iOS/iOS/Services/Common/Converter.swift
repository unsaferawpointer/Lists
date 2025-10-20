//
//  Converter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import CoreData

protocol Converter<T, U> {

	associatedtype T
	associatedtype U

	func convert(input: [T]) -> [U]
	func newEntity(for item: U, in context: NSManagedObjectContext) -> T
}
