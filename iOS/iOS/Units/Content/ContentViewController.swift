//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

protocol ContentViewDelegate: AnyObject, TableDelegate, ToolbarDelegate {
	func viewDidLoad()
	func contextMenuSelected(menuItem: String, with selection: [UUID])
	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>)
}

protocol ContentView: AnyObject {
	func display(newItems: [ContentItem])
	func display(toolbar: ContentToolbarModel)
	func displayTitle(title: String)
	func scroll(to id: UUID)
	var selection: [UUID] { get }
}

class ContentViewController: UIViewController {

	var delegate: ContentViewDelegate?

	lazy var toolbarManager: ContentToolbarManager = {
		let manager = ContentToolbarManager()
		manager.delegate = delegate
		return manager
	}()

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
		view.reorderingCadence = .immediate
		return view
	}()

	// MARK: - UIViewController life-cycle

	override func loadView() {
		self.view = UIView()
		configureConstraints()
		configureNavigationBar()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.register(
			UICollectionViewListCell.self,
			forCellWithReuseIdentifier: "cell"
		)
		adapter.delegate = delegate
		self.contentUnavailableConfiguration = nil
		delegate?.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
		invalidateToolbar()
		configureTitle()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		collectionView.isEditing = isEditing
		invalidateToolbar()
	}
}

// MARK: - ContentView
extension ContentViewController: ContentView {

	var selection: [UUID] {
		adapter.selection
	}

	func display(newItems: [ContentItem]) {
		adapter.reload(newItems: newItems)
		if adapter.isEmpty && isViewLoaded {
			var configuration = UIContentUnavailableConfiguration.empty()
			configuration.image = UIImage(systemName: "app.dashed")
			configuration.text = String(localized: "No items yet", table: "UnitLocalizable")
			configuration.secondaryText = String("To add a new item, tap the '+' button in the navigation bar.")
			self.contentUnavailableConfiguration = configuration
		} else {
			self.contentUnavailableConfiguration = nil
		}
		setNeedsUpdateContentUnavailableConfiguration()
	}

	func display(toolbar: ContentToolbarModel) {
		toolbarManager.updateStatus(toolbar: toolbar)
	}

	func displayTitle(title: String) {
		self.title = title
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
				collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}

	func configureTitle() {
		navigationItem.largeTitleDisplayMode = .never
	}

	func invalidateToolbar() {
		toolbarItems = toolbarManager.build(isEditing: isEditing)
		guard let model = delegate?.getToolbarModel() else {
			return
		}
		toolbarManager.updateStatus(toolbar: model)
	}

	func configureNavigationBar() {
		navigationItem.rightBarButtonItem = editButtonItem
	}
}

//#Preview {
//	ContentAssembly.build(id: nil, storage: PreviewStorage(), persistentContainer: <#NSPersistentContainer#>)
//}
