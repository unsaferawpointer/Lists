//
//  ObjectsRequest.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.12.2025.
//

import CoreData

protocol ObjectsRequest {

	associatedtype Entity: ManagedObject

	var value: NSFetchRequest<Entity> { get }
}
