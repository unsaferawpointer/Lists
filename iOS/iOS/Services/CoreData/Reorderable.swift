//
//  Reorderable.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import Foundation

protocol Reorderable: AnyObject {
	var offset: Int64 { get set }
}
