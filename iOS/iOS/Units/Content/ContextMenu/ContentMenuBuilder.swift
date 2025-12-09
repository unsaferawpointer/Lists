//
//  ContentMenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.11.2025.
//

import UIKit

final class ContentMenuBuilder {

	weak var delegate: ContextMenuDelegate?
}

extension ContentMenuBuilder {

	func build(selection: [UUID]) -> UIMenu {

		let actions: [UIAction] =
		[
			UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "edit", with: selection, state: .off)
			},
			UIAction(title: "Strikethrough", image: .strikethrough, state: state(for: "strikethrough", with: selection.first)) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "strikethrough", with: selection, state: self?.state(for: "strikethrough", with: selection.first) ?? .off)
			},
			UIAction(title: "List...", image: .listNumbered) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "move", with: selection, state: .off)
			},
			UIAction(title: "Tags...", image: .tag) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "tags", with: selection, state: .off)
			},
			UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
				self?.delegate?.contextMenuSelected(menuItem: "delete", with: selection, state: .off)
			}
		]

		let children = actions.map {
			UIMenu(options: .displayInline, children: [$0])
		}

		return UIMenu(children: children)
	}
}

// MARK: - Helpers
private extension ContentMenuBuilder {

	func state(for item: String, with id: UUID?) -> UIMenuElement.State {
		guard let id, let delegate else {
			return .off
		}
		return delegate.state(for: item, with: id)
	}
}
