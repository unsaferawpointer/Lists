//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.10.2025.
//

import SwiftUI

extension Icon: Identifiable {

	var id: RawValue { rawValue }
}

struct IconPicker {

	let icons: [Icon]
	let columns: Int

	@Binding var selectedIcon: Icon?

	private let gridItem: GridItem

	// MARK: - Initialization

	init(icons: [Icon] = Icon.allCases, selectedIcon: Binding<Icon?>, columns: Int = 1) {
		self.icons = icons
		self._selectedIcon = selectedIcon
		self.columns = columns
		self.gridItem = GridItem(.flexible())
	}
}

// MARK: - View
extension IconPicker: View {

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			LazyHGrid(rows: Array(repeating: gridItem, count: columns), spacing: 16) {
				ForEach(icons) { icon in
					IconCell(
						icon: icon,
						isSelected: selectedIcon?.id == icon.id
					)
					.onTapGesture {
						selectedIcon = icon
					}
				}
			}
		}
		.frame(height: CGFloat(columns) * 80) // Высота зависит от количества рядов
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
	IconPicker(selectedIcon: .constant(.cloud))
}
