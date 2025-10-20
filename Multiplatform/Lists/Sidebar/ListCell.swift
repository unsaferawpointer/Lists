//
//  ListCell.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI

#if os(macOS)
struct ListCell: View {

	@Bindable var list: ListEntity

	var body: some View {
		Label {
			TextField("", text: $list.name)
		} icon: {
			Image(systemName: (list.appearence?.icon ?? .noIcon).iconName)
		}
	}
}
#else
struct ListCell: View {

	@Bindable var list: ListEntity

	var body: some View {
		Label(list.name, systemImage: (list.appearence?.icon ?? .noIcon).iconName)
			.symbolColorRenderingMode(.gradient)
			.badge(list.items.count)
			.badgeProminence(.standard)
	}
}
#endif

#Preview(traits: .sizeThatFitsLayout) {
	ListCell(list: .init(timestamp: .now, name: "New List", appearence: .init(icon: .folder), items: []))
}
