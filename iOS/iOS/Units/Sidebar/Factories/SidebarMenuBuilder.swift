//
//  SidebarMenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.11.2025.
//

import UIKit

final class SidebarMenuBuilder {

	// MARK: - DI by Property

	weak var delegate: SidebarViewDelegate?

	// MARK: - DI by Initialization

	let availability: Availability

	// MARK: - Initialization

	init(availability: Availability = FeatureFacade()) {
		self.availability = availability
	}

}

extension SidebarMenuBuilder {

	func build(id: UUID) -> UIMenu {

		let actions = if availability.isEnabled(feature: .multipleWindows) {
			[
				UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
					self?.delegate?.contextMenu(didSelect: "edit", for: id)
				},
				UIAction(title: "New Window", image: UIImage(systemName: "macwindow.badge.plus")) { [weak self] _ in
					self?.delegate?.contextMenu(didSelect: "new-window", for: id)
				},
				UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
					self?.delegate?.contextMenu(didSelect: "delete", for: id)
				}
			]
		} else {
			[
				UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
					self?.delegate?.contextMenu(didSelect: "edit", for: id)
				},
				UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
					self?.delegate?.contextMenu(didSelect: "delete", for: id)
				}
			]
		}

		let children = actions.map {
			UIMenu(options: .displayInline, children: [$0])
		}

		return UIMenu(children: children)
	}
}
