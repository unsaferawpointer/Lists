//
//  SidebarTableAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.10.2025.
//

import UIKit

final class SidebarTableAdapter: NSObject {

	unowned var collectionView: UICollectionView

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

		let accessories: [UICellAccessory] = switch indexPath.section {
		case 0:
			[UICellAccessory.disclosureIndicator(displayed: .whenNotEditing, options: .init())]
		default:
			[
				UICellAccessory.disclosureIndicator(displayed: .whenNotEditing, options: .init()),
				UICellAccessory.reorder(displayed: .whenEditing, options: .init(tintColor: .systemGray))
			]
		}
		cell.accessories = accessories

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

extension SidebarTableAdapter {

	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 1
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

	}

	func collectionView(
		_ collectionView: UICollectionView,
		targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
		atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath
	) -> IndexPath {
		// Запрещаем перенос в секцию 0
			let forbiddenSection = 0

			if proposedIndexPath.section == forbiddenSection {
				// Возвращаем исходный indexPath или другой допустимый
				return originalIndexPath
			}

			return proposedIndexPath
	}
}

// MARK: - Menu Support
extension SidebarTableAdapter: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
		guard !collectionView.isEditing else {
			return nil
		}
		return UIContextMenuConfiguration(
			actionProvider: { _ in
				UIMenu(
					children:
						[
							UIMenu(
								options: .displayInline,
								children:
									[
										UIAction(title: "Edit...", image: UIImage(systemName: "trash")) { _ in

										}
									]
							),
							UIMenu(
								options: .displayInline,
								children:
									[
										UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in

										}
									]
							)
						]
				)
			}
		)
	}
}
