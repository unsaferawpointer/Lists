//
//  SidebarViewOutput.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.10.2025.
//

import Foundation

@MainActor
protocol SidebarViewDelegate: AnyObject {

	func viewDidLoad()

	func contextMenu(didSelect menuItem: String, for item: UUID)

	func newTag()

	func moveTag(with id: UUID, to destination: RelativeDestination<UUID>)
}
