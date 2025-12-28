//
//  TagsPickerModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.12.2025.
//

import Foundation

extension TagsPicker {

	@Observable
	final class Model {

		var selected: Set<UUID>

		var tags: [Tag] = []

		@ObservationIgnored
		let provider: DataProvider

		// MARK: - Initialization

		init(selected: Set<UUID>, provider: DataProvider) {
			self.selected = selected
			self.provider = provider
			Task { [weak self] in
				for await _ in provider.stream {
					await self?.fetchData()
				}
			}
		}
	}
}

// MARK: - Public Interface
extension TagsPicker.Model {

	@MainActor
	func fetchData() async {
		let request = TagsRequest()
		guard let tags = try? await provider.fetchObjects(with: request) else {
			return
		}
		self.tags = tags.map {
			Tag(uuid: $0.id, properties: .init(name: $0.properties.name))
		}
	}
}
