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

		return (removing, inserting)
	}
}

// MARK: - UICollectionViewDataSource
extension ContentTableAdapter: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		items.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let model = items[indexPath.row]

		var configuration = UIListContentConfiguration.cell()
		configuration.text = model.title

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewListCell
		cell.contentConfiguration = configuration

		cell.accessories =
		[
			UICellAccessory.multiselect(displayed: .whenEditing, options: .init(tintColor: .accent)),
			UICellAccessory.reorder(displayed: .whenEditing, options: .init(tintColor: .systemGray))
		]

		return cell
	}
}

extension ContentTableAdapter {

	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

	}
}

// MARK: - Menu Support
extension ContentTableAdapter: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

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
											UIAction(title: "Edit...", image: UIImage(systemName: "trash")) { [weak self] _ in
												self?.delegate?.contextMenuSelected(menuItem: "edit", with: ids)
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
