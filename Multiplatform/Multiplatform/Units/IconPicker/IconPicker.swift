//
//  IconPicker.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 07.01.2026.
//

import SwiftUI

struct IconPicker: View {

	@Binding var icon: Icon

	@State var icons: [Icon] = Icon.allCases

	let columns = [GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 20) {
				ForEach(icons) { icon in
					IconCell(
						icon: icon,
						isSelected: self.icon.id == icon.id
					)
					.onTapGesture {
						self.icon = icon
					}
				}
			}
			.padding()
		}
	}
}

struct IconCell: View {
	let icon: Icon
	let isSelected: Bool

	var body: some View {
		VStack(spacing: 8) {
			ZStack {
				Image(systemName: icon.systemName)
					.resizable()
					.scaledToFit()
					.frame(width: 32, height: 32)
			}
			.frame(width: 60, height: 60)
			.background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
			.cornerRadius(12)
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
			)

			// Название
			Text("Icon")
				.font(.caption2)
				.multilineTextAlignment(.center)
				.lineLimit(2)
				.foregroundColor(isSelected ? .blue : .primary)
		}
		.frame(width: 80)
	}
}


#Preview {
	IconPicker(icon: .constant(.star))
}
