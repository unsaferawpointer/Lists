//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

protocol ContentViewDelegate: AnyObject {
	func viewDidLoad()
	func editorDidCommit(text: String)
	func contextMenuSelected(menuItem: String, with selection: [UUID])
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
		return ContentTableAdapter(collectionView: collectionView)
	}()

	// MARK: - UI

	lazy var collectionView: UICollectionView = {

		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
			var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
			layoutConfig.showsSeparators = true
			 return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: layoutEnvironment)
		 }

		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.dragInteractionEnabled = true
		view.allowsMultipleSelectionDuringEditing = true
		return view
	}()

	lazy var editorView: ItemEditorView = {
		let view = ItemEditorView(frame: .zero)
		view.action = { [weak self] newText in
			self?.delegate?.editorDidCommit(text: newText)
		}

		let interaction = UIScrollEdgeElementContainerInteraction()
		interaction.scrollView = collectionView
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
		collectionView.register(
			UICollectionViewListCell.self,
			forCellWithReuseIdentifier: "cell"
		)
		adapter.delegate = delegate
		delegate?.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.contentInset.bottom = editorView.frame.height
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		collectionView.isEditing = isEditing
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
//		adapter.scroll(to: id)
	}
}

// MARK: - Helpers
private extension ContentViewController {

	func configureConstraints() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)

		NSLayoutConstraint.activate(
			[
				collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				collectionView.topAnchor.constraint(equalTo: view.topAnchor),
				collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
				collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
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
