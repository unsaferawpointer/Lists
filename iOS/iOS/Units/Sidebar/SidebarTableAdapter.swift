//
//  SidebarTableAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.10.2025.
//

import UIKit

final class SidebarTableAdapter: NSObject {

	unowned var tableView: UITableView

	// MARK: - Data

	private var main: [NavigationItem] =
	[
		.init(id: .all, iconName: "square.grid.2x2", title: "All", isEditable: false)
	]

	private var collection: [NavigationItem] = []

	// MARK: - Initialization

	init(tableView: UITableView) {
		self.tableView = tableView
		super.init()
		tableView.dataSource = self
	}
}

// MARK: - Public Interface
extension SidebarTableAdapter {

	func reload(newItems: [NavigationItem]) {

		let (removing, inserting) = calculate(newItems: newItems)
		print("___TEST removing = \(removing)")
		print("___TEST inserting = \(inserting)")
		self.collection = newItems

		tableView.beginUpdates()
		tableView.deleteRows(at: removing, with: .left)
		tableView.insertRows(at: inserting, with: .right)
		tableView.endUpdates()
	}
}

// MARK: - Helpers
private extension SidebarTableAdapter {

	func calculate(newItems: [NavigationItem]) -> ([IndexPath], [IndexPath]) {

		let collectionIndex = 1

		let diff = newItems.difference(from: collection) { old, new in
			return old.id == new.id
		}

		let removing = diff.compactMap { change -> Int? in
			guard case .remove(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: collectionIndex)
		}

		let inserting = diff.compactMap { change -> Int? in
			guard case .insert(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: collectionIndex)
		}

		return (removing, inserting)
	}
}

// MARK: - UITableViewDataSource
extension SidebarTableAdapter: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return main.count
		default:
			return collection.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let model = switch indexPath.section {
		case 0:
			main[indexPath.row]
		default:
			collection[indexPath.row]
		}

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.contentConfiguration = model.configuration
		return cell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return section == 1 ? "Collection" : nil
	}
}
