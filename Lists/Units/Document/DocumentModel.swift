//
//  DocumentModel.swift
//  Lists
//
//  Created by Anton Cherkasov on 19.09.2025.
//

import Foundation

@Observable
final class DocumentModel {

	var items: [ListItem] =
	[
		.init(text: "Закрыть спринт"),
		.init(text: "Купить книгу"),
		.init(text: "Починить кроссовки"),
		.init(
			text: "Закрыть спринт",
			subitems:
				[
					.init(text: "Закрыть спринт"),
					.init(text: "Купить книгу"),
					.init(text: "Починить кроссовки"),
					.init(
						text: "Закрыть спринт",
						subitems:
							[
								.init(text: "Закрыть спринт"),
								.init(text: "Купить книгу"),
								.init(text: "Закрыть спринт"),
							]
					),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
					.init(text: "Закрыть спринт"),
				]
		),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
		.init(text: "Закрыть спринт"),
	]
}

// MARK: - Public Interface
extension DocumentModel {

	func addItem() {
		
	}

	func deleteItems(with ids: Set<UUID>) {

	}
}
