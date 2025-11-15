//
//  SidebarPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import Foundation

protocol SidebarPresenterProtocol: AnyObject {
	func present(tags: [Tag])
}

final class SidebarPresenter {

	var interactor: SidebarInteractorProtocol?

	weak var view: SidebarView?

	var coordinator: SidebarCoordinatable?

	// MARK: - Initialization

	init(interactor: SidebarInteractorProtocol) {
		self.interactor = interactor
	}
}

// MARK: - SidebarViewDelegate
extension SidebarPresenter: SidebarViewDelegate {

	func viewDidLoad() {
		Task { @MainActor in
			try? await interactor?.fetchTags()
		}
	}

	func contextMenu(didSelect menuItem: String, for item: UUID) {
		switch menuItem {
		case "edit":
			Task { @MainActor in
				guard let tag = try? await interactor?.tag(for: item) else {
					return
				}
				let model = TagEditorModel(name: tag.name, icon: tag.properties.icon)
				coordinator?.presentTagEditor(with: model) { [weak self] isSuccess, newModel in
					guard isSuccess else {
						return
					}
					Task { @MainActor [weak self] in
						let properties = Tag.Properties(name: newModel.name, icon: newModel.icon)
						try? await self?.interactor?.updateTag(with: item, properties: properties)
					}
				}
			}
		case "new-window":
			coordinator?.openWindow(for: .tag(id: item))
		case "delete":
			interactor?.deleteTag(with: item)
		default:
			break
		}
	}

	func newTag() {
		let model = TagEditorModel(name: "")
		coordinator?.presentTagEditor(with: model) { [weak self] isSuccess, newModel in
			guard isSuccess else {
				return
			}
			Task { @MainActor [weak self] in
				let properties = Tag.Properties(name: newModel.name, icon: newModel.icon)
				try? await self?.interactor?.addTag(with: properties)
			}
		}
	}

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>) {
		Task {
			try? await interactor?.moveTag(with: id, to: destination)
		}
	}

}

// MARK: - SidebarPresenterProtocol
extension SidebarPresenter: SidebarPresenterProtocol {

	func present(tags: [Tag]) {
		Task { @MainActor in
			let items = convert(tags: tags)
			view?.display(newItems: items)
		}
	}
}

// MARK: - Helpers
private extension SidebarPresenter {

	func convert(tags: [Tag]) -> [NavigationItem] {
		tags.map { tag in
			NavigationItem(id: .tag(id: tag.id), iconName: tag.properties.icon?.iconName ?? "tag", title: tag.name)
		}
	}
}
