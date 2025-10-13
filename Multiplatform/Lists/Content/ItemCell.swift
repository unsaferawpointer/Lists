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
				Text(item.title)
					.strikethrough(
						item.strikeThrough,
						pattern: .solid,
						color: .secondary
					)
					.foregroundStyle(item.strikeThrough ? .primary : .primary)
					.font(.body)
					.textFieldStyle(.plain)
				if item.subtitle?.isEmpty == false {
					TextField("", text: .init($item.subtitle, default: ""))
						.foregroundStyle(.secondary)
						.font(.caption)
						.strikethrough(
							item.strikeThrough,
							pattern: .solid,
							color: .secondary
						)
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
			Circle()
				.foregroundStyle(.tertiary)
				.frame(width: 4, height: 4)
			VStack(alignment: .leading) {
				Text(item.title)
					.foregroundStyle(item.strikeThrough ? .secondary : .primary)
					.font(.body)
					.strikethrough(
						item.strikeThrough,
						pattern: .solid,
						color: .secondary
					)
			}
		}
	}
}
#endif

#Preview(traits: .sizeThatFitsLayout) {
	ItemCell(item: .init(timestamp: .now, title: "Default Item", strikeThrough: true, list: nil))
}
