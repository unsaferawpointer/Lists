//
//  SidebarViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

class SidebarViewController: UIViewController {

	var delegate: SidebarViewDelegate?

//	// MARK: - Data
//
//	var sections: [NavigationSection] = [
//		.init(
//			title: nil, items:
//				[
//					.init(id: .all,iconName: "square.grid.2x2", title: "All")
//				]
//		),
//		.init(
//			title: "Collection",
//			items:
//				[
//					.init(id: .list(id: UUID()), iconName: "star", title: "Today", isEditable: true),
//					.init(id: .list(id: UUID()), iconName: "doc.text", title: "Backlog", isEditable: true),
//					.init(id: .list(id: UUID()), iconName: "doc.text", title: "To Buy", isEditable: true)
//				]
//		)
//	]

	// MARK: - Data

	lazy var adapter: SidebarTableAdapter = {
		return SidebarTableAdapter(tableView: tableView)
	}()

	// MARK: - UI

	lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .insetGrouped)
		view.separatorStyle = .none
		view.showsVerticalScrollIndicator = false
		view.allowsSelection = true
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
		adapter.reload(newItems:
						[
							.init(id: .list(id: UUID()), iconName: "star", title: "First"),
							.init(id: .list(id: UUID()), iconName: "book", title: "Second")
						]
		)
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
