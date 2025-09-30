//
//  ActionView.swift
//  Lists
//
//  Created by Anton Cherkasov on 30.09.2025.
//

import SwiftUI

struct ActionCell: View {

	var body: some View {
		VStack {
			VStack(spacing: 8) {
				Image(systemName: "plus")
					.foregroundStyle(.tertiary)
					.font(.title)
				Text("Create Document")
					.foregroundStyle(.primary)
					.font(.headline)
					.lineLimit(2)
					.multilineTextAlignment(.center)
			}
			.padding(8)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(Color(.quaternarySystemFill))
		)
	}
}

#Preview {
	ActionCell()
		.frame(width: 150, height: 150)
}
