//
//  PersistentContainer.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import CoreData

protocol PersistentContainer {
	var mainContext: NSManagedObjectContext { get }
}
