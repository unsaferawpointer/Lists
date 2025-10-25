//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

protocol ContentViewDelegate: AnyObject {
	func viewDidLoad()
	func didTapAddButton()
	func contextMenuSelected(menuItem: String, with selection: [UUID])
	func moveItem(with id: UUID, to destination: RelativeDestination<UUID>)
}

protocol ContentView: AnyObject {
	func display(newItems: [ContentItem])
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
		view.reorderingCadence = .immediate
		return view
	}()

	// MARK: - UIViewController life-cycle

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
		self.contentUnavailableConfiguration = nil
		delegate?.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
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
		toolbarItems =
		[
			.flexibleSpace(),
			UIBarButtonItem(primaryAction: UIAction(title: "Add Item", image: UIImage(systemName: "plus"), handler: { [weak self] _ in
				self?.delegate?.didTapAddButton()
			}))
		]
	}
}

//#Preview {
//	ContentAssembly.build(id: nil, storage: PreviewStorage(), persistentContainer: <#NSPersistentContainer#>)
//}
