//
//  IconPicker.swift
//  Lists
//
//  Created by Anton Cherkasov on 06.10.2025.
//

import SwiftUI

struct IconPicker: View {

	@Binding var selectedIcon: Icon

	let icons: [Icon] = [.folder, .tray, .document, .stack, .star, .textPage]
	let columns: [GridItem]

	init(selectedIcon: Binding<Icon>, columnsCount: Int = 6) {
		self._selectedIcon = selectedIcon
		self.columns = Array(repeating: GridItem(.flexible()), count: columnsCount)
	}

	var body: some View {
		ScrollView(.horizontal) {
			LazyVGrid(columns: columns, spacing: 16) {
				ForEach(icons) { icon in
					IconCell(
						icon: icon,
						isSelected: selectedIcon.iconName == icon.iconName
					)
					.onTapGesture {
						selectedIcon = icon
					}
				}
			}
			.padding()
		}
	}
}

// Ячейка иконки
struct IconCell: View {

	let icon: Icon
	let isSelected: Bool

	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: icon.iconName)
				.font(.title2)
				.foregroundColor(isSelected ? .white : .primary)
				.frame(width: 50, height: 50)
				.background(
					RoundedRectangle(cornerRadius: 8)
						.fill(
							isSelected
								? Color.accentColor
								: Color.gray.opacity(0.05)
						)
				)
		}
		.animation(.easeInOut(duration: 0.2), value: isSelected)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	IconPicker(selectedIcon: .constant(.star))
		.frame(width: 240)
}
