//
//  DefautContainer.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import CoreData

final class DefaultContainer {

	private let base: NSPersistentContainer

	init (base: NSPersistentContainer) {
		self.base = base
	}
}

// MARK: - PersistentContainer
extension DefaultContainer: PersistentContainer {

	var mainContext: NSManagedObjectContext {
		base.viewContext
	}
}
