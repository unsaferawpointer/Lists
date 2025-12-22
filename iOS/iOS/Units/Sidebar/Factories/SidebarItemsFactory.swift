//
//  SidebarItemsFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 21.12.2025.
//

import Foundation

final class SidebarItemsFactory { }

extension SidebarItemsFactory {

	func items(filters: [Object<Filter.Properties, Filter.Relationships>]) -> [NavigationItem] {
		return filters.map {
			NavigationItem(
				id: .filter(id: $0.id),
				iconName: $0.properties.icon?.iconName ?? "list",
				title: $0.properties.name
			)
		}
	}

	func items(lists: [Object<List.Properties, List.Relationships>]) -> [NavigationItem] {
		return lists.map {
			NavigationItem(
				id: .list(id: $0.id),
				iconName: $0.properties.icon?.iconName ?? "list",
				title: $0.properties.name
			)
		}
	}
}
