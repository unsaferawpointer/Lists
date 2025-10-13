//
//  SidebarViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

class SidebarViewController: UIViewController {

	var delegate: SidebarViewDelegate?

	// MARK: - Data

	var sections: [NavigationSection] = [
		.init(
			title: nil, items:
				[
					.init(iconName: "square.grid.2x2", title: "All")
				]
		),
		.init(
			title: "Collection",
			items:
				[
					.init(iconName: "star", title: "Today", isEditable: true),
					.init(iconName: "doc.text", title: "Backlog", isEditable: true),
					.init(iconName: "doc.text", title: "To Buy", isEditable: true)
				]
		)
	]

	// MARK: - UI

	lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .insetGrouped)
		view.separatorStyle = .none
		view.showsVerticalScrollIndicator = false
		view.allowsSelection = true

		view.dataSource = self
		view.delegate = self

		return view
	}()

	override func loadView() {
		self.view = UIView()
		configureConstraints()
		configureNavigationBar()
		configureBottomBar()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: - Helpers
private extension SidebarViewController {

	func configureConstraints() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)

		NSLayoutConstraint.activate(
			[
				tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				tableView.topAnchor.constraint(equalTo: view.topAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}

	func configureNavigationBar() {
		navigationItem.rightBarButtonItem = editButtonItem
	}

	func configureBottomBar() {
		toolbarItems =
		[
			.flexibleSpace(),
			UIBarButtonItem(primaryAction: UIAction(title: "Add List", image: UIImage(systemName: "plus"), handler: { _ in

			}))
		]
	}
}

// MARK: - UITableViewDataSource
extension SidebarViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let item = sections[indexPath.section].items[indexPath.row]

		var configuration = UIListContentConfiguration.cell()
		configuration.image = UIImage(systemName: item.iconName)
		configuration.text = item.title
		configuration.textProperties.color = .label
		configuration.imageProperties.tintColor = UIColor.accent

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.contentConfiguration = configuration
		return cell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		sections[indexPath.section].items[indexPath.row].isEditable
	}
}

extension SidebarViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate?.didSelectItem(indexPath)
	}
}

extension SidebarViewController {

	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		sections[indexPath.section].items[indexPath.row].isEditable
	}

	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

	}

	func tableView(
		_ tableView: UITableView,
		targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
		toProposedIndexPath proposedDestinationIndexPath: IndexPath
	) -> IndexPath {
		guard proposedDestinationIndexPath.section == 1 else {
			return sourceIndexPath
		}
		return proposedDestinationIndexPath
	}
}

extension SidebarViewController {

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration { _ in
			return UIMenu(
				children:
					[
						UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in

						}
					]
			)
		}
	}
}
