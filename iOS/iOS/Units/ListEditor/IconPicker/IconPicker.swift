//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.10.2025.
//

import SwiftUI

struct IconPicker {

	let icons: [Icon]

	@Binding var selected: Icon?

	let columns: [GridItem] = [GridItem(.adaptive(minimum: 64), spacing: 24)]


	// MARK: - Initialization

	init(icons: [Icon] = Icon.allCases, selected: Binding<Icon?>) {
		self.icons = icons
		self._selected = selected
	}
}

// MARK: - View
extension IconPicker: View {

	var body: some View {
		Form {
			LazyVGrid(columns: columns, spacing: 15) {
				ForEach(icons, id: \.self) { icon in
					IconCell(
						icon: icon,
						isSelected: selected?.id == icon.id
					)
					.onTapGesture {
						selected = icon
					}
				}
			}
		}
		.navigationTitle("Choose icon")
	}
}

// Ячейка иконки
struct IconCell: View {
	let icon: Icon
	let isSelected: Bool

	var body: some View {
		ZStack {
			Image(systemName: icon.iconName)
				.font(.title2)
				.foregroundColor(isSelected ? .white : .primary)
		}
		.frame(width: 60, height: 60)
		.padding(8)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(isSelected ? Color.accent : Color.gray.opacity(0.1))
		)
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(isSelected ? Color.accent : Color.clear, lineWidth: 2)
		)
		.animation(.easeInOut(duration: 0.2), value: isSelected)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	IconCell(icon: .cloud, isSelected: false)
	IconCell(icon: .flame, isSelected: true)
}

#Preview(traits: .sizeThatFitsLayout) {
	IconPicker(selected: .constant(.cloud))
}
