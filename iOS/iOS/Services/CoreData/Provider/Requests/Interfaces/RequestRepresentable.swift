//
//  RequestRepresentable.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import Foundation

protocol RequestRepresentable {

	associatedtype Entity

	var nsPredicate: NSPredicate? { get }
	var nsSortDescriptors: [NSSortDescriptor]? { get }
	var fetchLimit: Int? { get }
}
