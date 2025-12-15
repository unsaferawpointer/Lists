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

// MARK: - Public Interface
extension SidebarMenuBuilder {

	func filterMenu(id: UUID) -> UIMenu {

		var actions: [UIAction] = [buildItem(id: "edit-filter", for: id)]
		if availability.isEnabled(feature: .multipleWindows) {
			actions.append(buildItem(id: "new-window", for: id))
		}
		actions.append(buildItem(id: "delete", for: id))

		let children = actions.map {
			UIMenu(options: .displayInline, children: [$0])
		}

		return UIMenu(children: children)
	}

	func projectMenu(id: UUID) -> UIMenu {

		var actions: [UIAction] = [buildItem(id: "edit-project", for: id)]
		if availability.isEnabled(feature: .multipleWindows) {
			actions.append(buildItem(id: "new-window", for: id))
		}
		actions.append(buildItem(id: "delete", for: id))

		let children = actions.map {
			UIMenu(options: .displayInline, children: [$0])
		}

		return UIMenu(children: children)
	}
}

extension SidebarMenuBuilder {

	func buildItem(id: String, for element: UUID) -> UIAction {
		switch id {
		case "new-window":
			UIAction(title: "New Window", image: UIImage(systemName: "macwindow.badge.plus")) { [weak self] _ in
				self?.delegate?.contextMenu(didSelect: id, for: element)
			}
		case "edit-project":
			UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
				self?.delegate?.contextMenu(didSelect: id, for: element)
			}
		case "edit-filter":
			UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] _ in
				self?.delegate?.contextMenu(didSelect: id, for: element)
			}
		case "delete":
			UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
				self?.delegate?.contextMenu(didSelect: id, for: element)
			}
		default:
			fatalError()
		}
	}
}
