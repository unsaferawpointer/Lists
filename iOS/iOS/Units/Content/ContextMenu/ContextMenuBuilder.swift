//
//  ContextMenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import UIKit

final class ContextMenuBuilder {

	weak var delegate: ContextMenuDelegate?
}

extension ContextMenuBuilder {

	func build(selection: [UUID]) -> UIMenu {

		let actions: [UIAction] =
		[
			UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "edit", with: selection)
			},
			UIAction(title: "Strikethrough", image: .strikethrough) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "strikethrough", with: selection)
			},
			UIAction(title: "Move to...", image: .arrowLeftRight) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "move", with: selection)
			},
			UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "delete", with: selection)
			}
		]

		let children = actions.map {
			UIMenu(options: .displayInline, children: [$0])
		}

		return UIMenu(children: children)
	}
}
