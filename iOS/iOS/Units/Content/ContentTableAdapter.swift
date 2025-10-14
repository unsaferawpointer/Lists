//
//  ContentTableAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.10.2025.
//

import UIKit

final class ContentTableAdapter: NSObject {

	unowned var tableView: UITableView

	// MARK: - Data

	private var items: [ContentItem] = []

	// MARK: - Initialization

	init(tableView: UITableView) {
		self.tableView = tableView
		super.init()
		tableView.dataSource = self
	}
}

// MARK: - Public Interface
extension ContentTableAdapter {

	func reload(newItems: [ContentItem]) {

		let (removing, inserting) = calculate(newItems: newItems)

		tableView.beginUpdates()
		tableView.deleteRows(at: removing, with: .left)
		tableView.insertRows(at: inserting, with: .right)
		tableView.endUpdates()
	}
}

// MARK: - Helpers
private extension ContentTableAdapter {

	func calculate(newItems: [ContentItem]) -> ([IndexPath], [IndexPath]) {
		let diff = newItems.difference(from: items) { old, new in
			return old.id == new.id
		}

		let removing = diff.compactMap { change -> Int? in
			guard case .remove(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: 0)
		}

		let inserting = diff.compactMap { change -> Int? in
			guard case .insert(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: 0)
		}

		self.items = newItems

		return (removing, inserting)
	}
}

// MARK: - UITableViewDataSource
extension ContentTableAdapter: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		configure(cell: cell, at: indexPath.row)
		return cell
	}
}

// MARK: - Helpers
private extension ContentTableAdapter {

	func numberOfRows() -> Int {
		return items.count
	}

	func configure(cell: UITableViewCell, at row: Int) {
		cell.contentConfiguration = items[row].configuration
	}
}
