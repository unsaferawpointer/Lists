//
//  ContentTableAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.10.2025.
//

import UIKit

final class ContentTableAdapter: NSObject {

	unowned var collectionView: UICollectionView

	weak var delegate: ContentViewDelegate?

	// MARK: - Data

	var items: [ContentItem] = []

	// MARK: - Initialization

	init(collectionView: UICollectionView) {
		self.collectionView = collectionView
		super.init()

		collectionView.dataSource = self
		collectionView.delegate = self
	}
}

// MARK: - Public Interface
extension ContentTableAdapter {

	func reload(newItems: [ContentItem]) {

		guard !(newItems.isEmpty && items.isEmpty) else {
			collectionView.reloadData()
			return
		}

		let (removing, inserting) = calculate(newItems: newItems)

		collectionView.performBatchUpdates {
			self.items = newItems

			collectionView.deleteItems(at: removing)
			collectionView.insertItems(at: inserting)
		}
	}

	var isEmpty: Bool {
		return items.isEmpty
	}

	var selection: [UUID] {
		return collectionView.indexPathsForSelectedItems?.map {
			items[$0.row].id
		} ?? []
	}
}

// MARK: - Helpers
private extension ContentTableAdapter {

	func calculate(newItems: [ContentItem]) -> ([IndexPath], [IndexPath]) {

		let diff = newItems.difference(from: items) { old, new in
			return old.id == new.id
		}

		updateCells(newItems: newItems, in: 0)

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

		return (removing, inserting)
	}

	func updateCells(newItems: [ContentItem], in section: Int) {

		var newCache: [UUID: Int] = [:]
		var oldCache: [UUID: Int] = [:]

		for (index, item) in items.enumerated() {
			oldCache[item.id] = index
		}

		for (index, item) in newItems.enumerated() {
			newCache[item.id] = index
		}

		let intersection = Set(newItems.map(\.id)).intersection(items.map(\.id))
		for id in intersection {
			guard let oldIndex = oldCache[id], let newIndex = newCache[id] else {
				continue
			}
			let newModel = newItems[newIndex]
			let indexPath = IndexPath(row: oldIndex, section: section)
			let cell = collectionView.cellForItem(at: indexPath)

			let configuration = UIHostingConfiguration {
				HStack(spacing: 16) {
					VStack(alignment: .leading) {
						Text(newModel.title)
							.foregroundStyle(newModel.isStrikethrough ? .secondary : .primary)
							.font(.body)
							.strikethrough(
								newModel.isStrikethrough,
								pattern: .solid,
								color: .secondary
							)
					}
				}
			}

			cell?.contentConfiguration = configuration
		}
	}
}

import SwiftUI

// MARK: - UICollectionViewDataSource
extension ContentTableAdapter: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		items.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let model = items[indexPath.row]

		let configuration = UIHostingConfiguration {
			HStack(spacing: 16) {
				VStack(alignment: .leading) {
					Text(model.title)
						.foregroundStyle(model.isStrikethrough ? .secondary : .primary)
						.font(.body)
						.strikethrough(
							model.isStrikethrough,
							pattern: .solid,
							color: .secondary
						)
				}
			}
		}

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewListCell
		cell.contentConfiguration = configuration

		cell.accessories =
		[
			UICellAccessory.multiselect(displayed: .whenEditing, options: .init(tintColor: .accent)),
			UICellAccessory.reorder(displayed: .whenEditing, options: .init(tintColor: .systemGray)),
			UICellAccessory.customView(
				configuration: .init(
					customView: UIImageView(image: UIImage(resource: .point)),
					placement: .leading(displayed: .whenNotEditing),
					tintColor: .tertiaryLabel
				)
			)
		]

		return cell
	}
}

// MARK: - Selection Support
extension ContentTableAdapter {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.table(didUpdateSelection: selection)
	}

	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		delegate?.table(didUpdateSelection: selection)
	}
}

// MARK: - Moving Support
extension ContentTableAdapter {

	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let id = items[sourceIndexPath.row].id

		let destination: RelativeDestination<UUID> = if sourceIndexPath.row < destinationIndexPath.row {
			destinationIndexPath.row < items.count - 1 ? .before(id: items[destinationIndexPath.row + 1].id) : .after(id: items[destinationIndexPath.row].id)
		} else {
			.before(id: items[destinationIndexPath.row].id)
		}

		let item = items.remove(at: sourceIndexPath.row)
		items.insert(item, at: destinationIndexPath.row)

		delegate?.moveItem(with: id, to: destination)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
		atCurrentIndexPath currentIndexPath: IndexPath,
		toProposedIndexPath proposedIndexPath: IndexPath
	) -> IndexPath {
		proposedIndexPath
	}
}

// MARK: - Menu Support
extension ContentTableAdapter: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

		guard !collectionView.isEditing else {
			return nil
		}

		let ids = indexPaths.map(\.row).map {
			items[$0].id
		}

		if ids.count == 1 {
			return UIContextMenuConfiguration(
				actionProvider: { [weak self] _ in
					UIMenu(
						children:
							[
								UIMenu(
									options: .displayInline,
									children:
										[
											UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
												self?.delegate?.contextMenuSelected(menuItem: "edit", with: ids)
											}
										]
								),
								UIMenu(
									options: .displayInline,
									children:
										[
											UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough")) { [weak self] _ in
												self?.delegate?.contextMenuSelected(menuItem: "strikethrough", with: ids)
											}
										]
								),
								UIMenu(
									options: .displayInline,
									children:
										[
											UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
												self?.delegate?.contextMenuSelected(menuItem: "delete", with: ids)
											}
										]
								)
							]
					)
				}
			)
		}

		return UIContextMenuConfiguration(
			actionProvider: { [weak self] _ in
				UIMenu(
					children:
						[
							UIMenu(
								options: .displayInline,
								children:
									[
										UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough")) { [weak self] _ in
											self?.delegate?.contextMenuSelected(menuItem: "strikethrough", with: ids)
										}
									]
							),
							UIMenu(
								options: .displayInline,
								children:
									[
										UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
											self?.delegate?.contextMenuSelected(menuItem: "delete", with: ids)
										}
									]
							)
						]
				)
			}
		)
	}
}
