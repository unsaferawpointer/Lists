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
	let provider: DataProvider<List, ListEntity>

	init(provider: DataProvider<List, ListEntity>) {
		self.provider = provider
		Task { @MainActor in
			for await change in provider.contentChanges {
				self.lists = change
			}
		}
	}
}
