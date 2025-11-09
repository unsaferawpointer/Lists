//
//  ListPickerModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.10.2025.
//

import Foundation

@Observable
final class ListPickerModel {

	var lists: [List] = []

	@ObservationIgnored
	let provider: ModelsProvider<List>

	init(provider: ModelsProvider<List>) {
		self.provider = provider
		Task { @MainActor in
			for await change in await provider.stream() {
				self.lists = change
			}
		}
	}
}
