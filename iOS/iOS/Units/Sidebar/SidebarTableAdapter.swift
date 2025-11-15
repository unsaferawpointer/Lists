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

	var sections: [Section] = [
		.init(title: "", tinted: true, items: [.init(id: .all, iconName: "square.grid.2x2", title: "All")]),
		.init(title: "Tags", tinted: false, items: [])
	]

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

		let (removing, inserting) = calculate(newItems: newItems, in: 1)

		collectionView.performBatchUpdates {
			self.sections[1].items = newItems

			collectionView.deleteItems(at: removing)
			collectionView.insertItems(at: inserting)
		}
	}

	var isEmpty: Bool {
		return sections[1].items.isEmpty
	}
}

// MARK: - Nested Data Structs
extension SidebarTableAdapter {

	struct Section {
		let title: String
		let tinted: Bool
		var items: [NavigationItem]
	}
}

extension SidebarTableAdapter.Section {

	subscript(index: Int) -> NavigationItem {
		get {
			items[index]
		}
		set {
			items[index] = newValue
		}
	}
}

// MARK: - Helpers
private extension SidebarTableAdapter {

	func calculate(newItems: [NavigationItem], in section: Int) -> ([IndexPath], [IndexPath]) {

		updateCells(newItems: newItems, in: section)

		let oldItems = sections[section].items
		let diff = newItems.difference(from: oldItems) { old, new in
			return old.id == new.id
		}

		let removing = diff.compactMap { change -> Int? in
			guard case .remove(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: section)
		}

		let inserting = diff.compactMap { change -> Int? in
			guard case .insert(let offset, _, _) = change else {
				return nil
			}
			return offset
		}.map {
			IndexPath(row: $0, section: section)
		}

		return (removing, inserting)
	}

	func updateCells(newItems: [NavigationItem], in section: Int) {

		var newCache: [NavigationItem.ID: Int] = [:]
		var oldCache: [NavigationItem.ID: Int] = [:]

		let oldItems = sections[section].items

		for (index, item) in oldItems.enumerated() {
			oldCache[item.id] = index
		}

		for (index, item) in newItems.enumerated() {
			newCache[item.id] = index
		}

		let intersection = Set(newItems.map(\.id)).intersection(oldItems.map(\.id))
		for id in intersection {
			guard let oldIndex = oldCache[id], let newIndex = newCache[id] else {
				continue
			}
			let newModel = newItems[newIndex]
			let indexPath = IndexPath(row: oldIndex, section: section)
			let cell = collectionView.cellForItem(at: indexPath)
			cell?.contentConfiguration = configuration(for: newModel, tinted: sections[section].tinted)
		}
	}

	func configuration(for model: NavigationItem, tinted: Bool) -> any UIContentConfiguration {
		var configuration = UIListContentConfiguration.cell()
		configuration.text = model.title
		configuration.image = UIImage(systemName: model.iconName)
		configuration.imageProperties.tintColor = tinted ? .accent : .label
		configuration.textProperties.color = .label
		return configuration
	}
}

// MARK: - UICollectionViewDataSource
extension SidebarTableAdapter: UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sections[section].items.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let section = sections[indexPath.section]
		let model = section[indexPath.row]

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewListCell
		cell.contentConfiguration = configuration(for: model, tinted: section.tinted)

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

		let section = sections[indexPath.section]

		var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
		configuration.text = section.title

		header.contentConfiguration = configuration

		return header
	}
}

// MARK: - Selection Support
extension SidebarTableAdapter {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let model = sections[indexPath.section][indexPath.row]
		onSelect?(model)
	}
}

// MARK: - Moving Support
extension SidebarTableAdapter {

	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 1
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

		let items = sections[sourceIndexPath.section].items

		guard case let .tag(id) = items[sourceIndexPath.row].id else {
			return
		}

		let destination: RelativeDestination<NavigationItem.ID> = if sourceIndexPath.row < destinationIndexPath.row {
			destinationIndexPath.row < items.count - 1 ? .before(id: items[destinationIndexPath.row + 1].id) : .after(id: items[destinationIndexPath.row].id)
		} else {
			.before(id: items[destinationIndexPath.row].id)
		}

		let item = sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
		sections[sourceIndexPath.section].items.insert(item, at: destinationIndexPath.row)

		let newDestination = destination.map { item -> UUID? in
			guard case .tag(let id) = item else {
				return nil
			}
			return id
		}

		guard let newDestination else {
			return
		}

		delegate?.moveTag(with: id, to: newDestination)
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

		let item = sections[indexPath.section][indexPath.row]
		guard case let .tag(id) = item.id else {
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
