//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

protocol ContentViewDelegate {
	func viewDidLoad()
	func editorDidCommit(text: String)
}

protocol ContentView: AnyObject {
	func display(newItems: [ContentItem])
	func displayEditor(_ model: ItemEditorModel)
	func scroll(to id: UUID)
}

class ContentViewController: UIViewController {

	var delegate: ContentViewDelegate?

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

	lazy var editorView: ItemEditorView = {
		let view = ItemEditorView(frame: .zero)
		view.action = { [weak self] newText in
			self?.delegate?.editorDidCommit(text: newText)
		}

		let interaction = UIScrollEdgeElementContainerInteraction()
		interaction.scrollView = tableView
		interaction.edge = .bottom

		view.addInteraction(interaction)
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
		delegate?.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.contentInset.bottom = editorView.frame.height
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: - ContentView
extension ContentViewController: ContentView {

	func display(newItems: [ContentItem]) {
		adapter.reload(newItems: newItems)
	}

	func displayEditor(_ model: ItemEditorModel) {
		editorView.model = model
	}

	func scroll(to id: UUID) {
		adapter.scroll(to: id)
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
				tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
			]
		)
	}

	func configureNavigationBar() {
		navigationItem.rightBarButtonItem = editButtonItem
	}

	func configureBottomBar() {
		view.addSubview(editorView)
		editorView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate(
			[
				editorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
				editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
				editorView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: 0)
			]
		)

	}
}

#Preview {
	ContentAssembly.build(id: nil, storage: PreviewStorage())
}
