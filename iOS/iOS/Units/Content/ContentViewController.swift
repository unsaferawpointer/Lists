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

	var items: [ContentItem] =
	[
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1"),
		.init(title: "Item 1")
	]

	// MARK: - UI

	lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.separatorStyle = .singleLine
		view.showsVerticalScrollIndicator = false
		view.allowsSelection = true
		view.allowsMultipleSelection = true
		view.allowsMultipleSelectionDuringEditing = true

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

// MARK: - UITableViewDataSource
extension ContentViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let item = items[indexPath.row]

		var configuration = UIListContentConfiguration.cell()
		configuration.text = item.title
		configuration.textProperties.color = .label

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.selectionStyle = .default
		cell.contentConfiguration = configuration
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
}

extension ContentViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate?.didSelectItem(indexPath)
	}
}

extension ContentViewController {

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard !tableView.isEditing else {
			return nil
		}
		let configuration = UIContextMenuConfiguration { _ in
			return UIMenu(
				children:
					[
						UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in

						}
					]
			)
		}
		return configuration
	}
}
