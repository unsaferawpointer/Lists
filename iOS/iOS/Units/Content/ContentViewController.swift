//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

class ContentViewController: UIViewController {

	var delegate: SidebarViewDelegate?

	// MARK: - Data

	lazy var adapter: ContentTableAdapter = {
		return ContentTableAdapter(tableView: tableView)
	}()

	// MARK: - UI

	lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.separatorStyle = .singleLine
		view.showsVerticalScrollIndicator = false
		view.allowsSelection = false
		view.allowsMultipleSelection = false
		view.allowsMultipleSelectionDuringEditing = true
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
		adapter.reload(newItems: [.init(title: "First"), .init(title: "Second")])
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
private extension ContentViewController {

	func configureConstraints() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)

		NSLayoutConstraint.activate(
			[
				tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				tableView.topAnchor.constraint(equalTo: view.topAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
