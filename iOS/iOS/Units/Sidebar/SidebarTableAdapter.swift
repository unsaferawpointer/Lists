//
//  SidebarTableAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.10.2025.
//

import UIKit
import SwiftUI

final class SidebarTableAdapter: NSObject {

	unowned var collectionView: UICollectionView

	weak var delegate: SidebarViewDelegate?

	// MARK: - Handlers

	var onSelect: ((NavigationItem) -> Void)?

	// MARK: - Data

		var main: [NavigationItem] = [.init(id: .all, iconName: "square.grid.2x2", title: "All")]

		var collection: [NavigationItem] = []

	// MARK: - Initialization

	init(collectionView: UICollectionView) {
		self.collectionView = collectionView
		super.init()

		collectionView.dataSource = self
		collectionView.delegate = self
	}
}

// MARK: - Public Interface
extension SidebarTableAdapter {

	func reload(newItems: [NavigationItem]) {

		let (removing, inserting) = calculate(newItems: newItems)

		collectionView.performBatchUpdates {
			self.collection = newItems

			collectionView.deleteItems(at: removing)
			collectionView.insertItems(at: inserting)
		}
	}

	var isEmpty: Bool {
		return collection.isEmpty
	}
}

// MARK: - Helpers
private extension SidebarTableAdapter {

	func calculate(newItems: [NavigationItem]) -> ([IndexPath], [IndexPath]) {

		let collectionIndex = 1

		updateCells(newItems: newItems, in: collectionIndex)

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

	func updateCells(newItems: [NavigationItem], in section: Int) {

		var newCache: [NavigationItem.ID: Int] = [:]
		var oldCache: [NavigationItem.ID: Int] = [:]

		for (index, item) in collection.enumerated() {
			oldCache[item.id] = index
		}

		for (index, item) in newItems.enumerated() {
			newCache[item.id] = index
		}

		let intersection = Set(newItems.map(\.id)).intersection(collection.map(\.id))
		for id in intersection {
			guard let oldIndex = oldCache[id], let newIndex = newCache[id] else {
				continue
			}
			let newModel = newItems[newIndex]
			let indexPath = IndexPath(row: oldIndex, section: section)
			let cell = collectionView.cellForItem(at: indexPath)

			var configuration = UIListContentConfiguration.cell()
			configuration.text = newModel.title
			configuration.image = UIImage(systemName: newModel.iconName)

			cell?.contentConfiguration = configuration
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SidebarTableAdapter: UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0:
			return main.count
		default:
			return collection.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let model: NavigationItem = switch indexPath.section {
			case 0: 	main[indexPath.row]
			default: 	collection[indexPath.row]
		}

		var configuration = UIListContentConfiguration.cell()
		configuration.text = model.title
		configuration.image = UIImage(systemName: model.iconName)

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewListCell
		cell.contentConfiguration = configuration

		// MARK: - Configure Accessories

		let reorderAccessory = UICellAccessory.reorder(displayed: .whenEditing, options: .init(tintColor: .systemGray))

		cell.accessories = indexPath.section == 1 ? [reorderAccessory] : []

		return cell
	}

	func collectionView(_ collectionView: UICollectionView,
					   viewForSupplementaryElementOfKind kind: String,
					   at indexPath: IndexPath) -> UICollectionReusableView {

		let header = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: "header",
			for: indexPath
		) as! UICollectionViewListCell

		var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()

		switch indexPath.section {
			case 0: 	configuration.text = "Main"
			default: 	configuration.text = "Collection"
		}

		header.contentConfiguration = configuration

		return header
	}
}

// MARK: - Selection Support
extension SidebarTableAdapter {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let model: NavigationItem = switch indexPath.section {
			case 0: 	main[indexPath.row]
			default: 	collection[indexPath.row]
		}
		onSelect?(model)
	}
}


extension SidebarTableAdapter {

	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 1
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		guard case let .list(id) = collection[sourceIndexPath.row].id else {
			return
		}

		let destination: RelativeDestination<NavigationItem.ID> = if sourceIndexPath.row < destinationIndexPath.row {
			destinationIndexPath.row < collection.count - 1 ? .before(id: collection[destinationIndexPath.row + 1].id) : .after(id: collection[destinationIndexPath.row].id)
		} else {
			.before(id: collection[destinationIndexPath.row].id)
		}

		let item = collection.remove(at: sourceIndexPath.row)
		collection.insert(item, at: destinationIndexPath.row)

		let newDestination = destination.map { item -> UUID? in
			guard case .list(let id) = item else {
				return nil
			}
			return id
		}

		guard let newDestination else {
			return
		}

		delegate?.moveList(with: id, to: newDestination)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
		atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath
	) -> IndexPath {
		return proposedIndexPath.section == 1 ? proposedIndexPath : originalIndexPath
	}
}

// MARK: - Menu Support
extension SidebarTableAdapter: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
		guard
			!collectionView.isEditing, indexPaths.count == 1,
			let indexPath = indexPaths.first, indexPath.section == 1 else {
			return nil
		}

		let item = collection[indexPath.row]
		guard case let .list(id) = item.id else {
			return nil
		}

		let builder = SidebarMenuBuilder()
		builder.delegate = delegate

		return UIContextMenuConfiguration(
			actionProvider: { _ in
				builder.build(id: id)
			}
		)
	}
}
