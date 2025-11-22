//
//  ListPickerModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import Foundation

@Observable
final class ListPickerModel {

	var selected: UUID?

	var lists: [List] = []

	@ObservationIgnored
	let provider: ModelsProvider<List>

	init(selected: UUID?, provider: ModelsProvider<List>) {
		self.selected = selected
		self.provider = provider
		Task { @MainActor in
			for await change in await provider.stream() {
				self.lists = change
			}
		}
	}
}
