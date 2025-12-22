//
//  FilteredContent + Interactor.swift
//  iOS
//
//  Created by Anton Cherkasov on 20.12.2025.
//

import Foundation
import CoreData

extension FilteredContent {

	final class Interactor {

		let identifier: UUID

		private let provider: DataProvider<FilterEntity>

		// MARK: - Initialization

		init(identifier: UUID, provider: DataProvider<FilterEntity>) {
			self.identifier = identifier
			self.provider = provider

			Task { [weak self] in
				for await _ in provider.stream {
					self?.fetchData()
				}
			}
		}
	}
}

extension FilteredContent.Interactor {

	func fetchData() {

	}
}
