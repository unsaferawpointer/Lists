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

	var lists: [Object<List.Properties, List.Relationships>] = []

	@ObservationIgnored
	let provider: DataProvider

	// MARK: - Initialization

	init(selected: UUID?, provider: DataProvider) {
		self.selected = selected
		self.provider = provider
		Task {
			for await _ in provider.stream {
				await fetchData()
			}
		}
	}
}

// MARK: - Public Interface
extension ListPickerModel {

	@MainActor
	func fetchData() async {
		let request = ListsRequest()
		guard let fetchedLists = try? await provider.fetchObjects(with: request) else {
			return
		}
		self.lists = fetchedLists
	}
}
