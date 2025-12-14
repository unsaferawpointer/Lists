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

	func newList()

	func newFilter()

	func moveList(with id: UUID, to destination: RelativeDestination<UUID>)
}
