//
//   Predicate.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.10.2025.
//

import CoreData

protocol Predicate {
	var value: NSPredicate? { get }
}
