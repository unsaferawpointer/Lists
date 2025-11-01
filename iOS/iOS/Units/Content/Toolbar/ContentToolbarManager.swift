//
//  ContentToolbarManager.swift
//  iOS
//
//  Created by Anton Cherkasov on 26.10.2025.
//

import UIKit

final class ContentToolbarManager {

	lazy var primaryItem: UIBarButtonItem = {
		let item = UIBarButtonItem()
		item.identifier = "right-item"

		item.image = .plus
		item.primaryAction = UIAction(title: "New Item", image: .plus, identifier: .init(.newItem)) { [weak self] _ in
			self?.delegate?.didSelectToolbarItem(with: "new", state: .off)
		}
		return item
	}()

	lazy var secondaryItem: UIBarButtonItem = {
		let item = UIBarButtonItem()
		item.identifier = "right-item"

		item.image = .ellipsis
		item.menu = UIMenu(
			image: .ellipsis,
			identifier: .init("secondary-menu"),
			children: buildMenu(state: [:])
		)
		return item
	}()

	lazy var statusItem: UIBarButtonItem = {

		let label = UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .headline)

		let item = UIBarButtonItem(customView: label)
		item.hidesSharedBackground = true

		return item
	}()

	// MARK: - DI

	weak var delegate: ToolbarDelegate?
}

// MARK: - Public Interface
extension ContentToolbarManager {

	func build(isEditing: Bool) -> [UIBarButtonItem] {
		guard isEditing else {
			return [.flexibleSpace(), primaryItem]
		}
		return [.flexibleSpace(), statusItem, .flexibleSpace(), secondaryItem]
	}

	func updateStatus(toolbar: ContentToolbarModel) {
		if let label = statusItem.customView as? UILabel {
			label.text = toolbar.status.title
			label.sizeToFit()
		}
		secondaryItem.isEnabled = toolbar.secondary.isEnadled
		secondaryItem.menu = UIMenu(children: buildMenu(state: toolbar.secondary.state))
	}
}

// MARK: - Helpers
private extension ContentToolbarManager {

	func buildMenu(state: [String: UIMenuElement.State]) -> [UIMenuElement] {
		[
			UIAction(title: "Move To...", image: .arrowLeftRight, identifier: .init(.move), state: state["move"] ?? .off) { [weak self] _ in
				self?.delegate?.didSelectToolbarItem(with: "move", state: state["move"] ?? .off)
			},
			UIAction(title: "Strikethrough", image: .strikethrough, identifier: .init(.strikeThrough), state: state["strikethrough"] ?? .off) { [weak self] _ in
				self?.delegate?.didSelectToolbarItem(with: "strikethrough", state: state["strikethrough"] ?? .off)
			},
			UIAction(title: "Delete", image: .trash, identifier: .init(.delete), attributes: .destructive, state: state["delete"] ?? .off) { [weak self] _ in
				self?.delegate?.didSelectToolbarItem(with: "delete", state: state["delete"] ?? .off)
			}
		]
	}
}
