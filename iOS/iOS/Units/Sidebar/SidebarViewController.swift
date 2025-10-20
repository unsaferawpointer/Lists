//
//  SidebarViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import UIKit

@MainActor
protocol SidebarView: AnyObject {
	func display(newItems: [NavigationItem])
}

class SidebarViewController: UIViewController {

	var delegate: SidebarViewDelegate?

	weak var selectionDelegate: SelectionDelegate?

	lazy var adapter: SidebarTableAdapter = {
		let adapter = SidebarTableAdapter(collectionView: collectionView)
		adapter.onSelect = { [weak self] model in
			self?.selectionDelegate?.didSelect(item: model)
		}
		return adapter
	}()

	// MARK: - UI

	lazy var collectionView: UICollectionView = {

		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
			var layoutConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
			layoutConfig.showsSeparators = false

			layoutConfig.headerMode = sectionIndex == 0 ? .none : .supplementary

			 return NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: layoutEnvironment)
		 }

		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.dragInteractionEnabled = true
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
		collectionView.register(
			UICollectionViewListCell.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: "header"
		)

		adapter.delegate = delegate
		delegate?.viewDidLoad()

		collectionView.selectItem(at: .init(row: 0, section: 0), animated: true, scrollPosition: .top)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: true)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		collectionView.isEditing = editing
	}
}

// MARK: - SidebarView
extension SidebarViewController: SidebarView {

	func display(newItems: [NavigationItem]) {
		adapter.reload(newItems: newItems)
	}
}

// MARK: - Helpers
private extension SidebarViewController {

	func configureConstraints() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)

		NSLayoutConstraint.activate(
			[
				collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				collectionView.topAnchor.constraint(equalTo: view.topAnchor),
				collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
			UIBarButtonItem(primaryAction: UIAction(title: "Add List", image: UIImage(systemName: "plus"), handler: { [weak self] _ in
				self?.delegate?.newList()
			}))
		]
	}
}

import SwiftUI

//#Preview {
//	SidebarAssembly.build(storage: PreviewStorage(), persistentContainer: <#NSPersistentContainer#>)
//}
