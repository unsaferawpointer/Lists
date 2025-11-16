//
//  TagPickerModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import Foundation

@Observable
final class TagPickerModel {

	var selected: Set<UUID>

	var tags: [Tag] = []

	@ObservationIgnored
	let provider: ModelsProvider<Tag>

	init(selected: Set<UUID>, provider: ModelsProvider<Tag>) {
		self.selected = selected
		self.provider = provider
		Task { @MainActor in
			for await change in await provider.stream() {
				self.tags = change
			}
		}
	}
}

// MARK: - Public Interface
extension TagPickerModel {

	func toggle(id: UUID) {
		if selected.contains(id) {
			selected.remove(id)
		} else {
			selected.insert(id)
		}
	}
}
