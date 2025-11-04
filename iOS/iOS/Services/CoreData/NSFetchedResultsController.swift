//
//  NSFetchedResultsController.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

import CoreData

extension NSFetchedResultsController {

	@objc
	convenience init(fetchRequest: NSFetchRequest<ResultType>, managedObjectContext: NSManagedObjectContext) {
		self.init(
			fetchRequest: fetchRequest,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}
}
