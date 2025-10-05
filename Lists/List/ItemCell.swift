//
//  ItemCell.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI

#if os(macOS)
struct ItemCell: View {

	@Bindable var item: ItemEntity

	var body: some View {
		HStack {
			Circle()
				.foregroundStyle(.tertiary)
				.frame(width: 4, height: 4)
			VStack(alignment: .leading) {
				TextField("", text: $item.title)
					.foregroundStyle(.primary)
					.font(.headline)
				if item.subtitle?.isEmpty == false {
					TextField("", text: .init($item.subtitle, default: ""))
						.foregroundStyle(.secondary)
						.font(.caption)
				}
			}
		}
	}
}
#else
struct ItemCell: View {

	@Bindable var item: ItemEntity

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				TextField("", text: $item.title)
					.foregroundStyle(.primary)
					.font(.headline)
				Text(UUID().uuidString)
					.foregroundStyle(.secondary)
					.font(.caption)
			}
		}
	}
}
#endif

#Preview(traits: .sizeThatFitsLayout) {
	ItemCell(item: .init(timestamp: .now, title: "Default Item", list: nil))
}
