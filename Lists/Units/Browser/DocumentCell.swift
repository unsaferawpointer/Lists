//
//  DocumentCell.swift
//  Lists
//
//  Created by Anton Cherkasov on 30.09.2025.
//

import SwiftUI

struct DocumentCell: View {

	var body: some View {
		VStack {
			VStack {
				Image(systemName: "doc.text")
					.foregroundStyle(.tertiary)
					.font(.title)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 8)
					.fill(Color(.quaternarySystemFill))
			)
			Text("Backlog")
				.foregroundStyle(.primary)
				.font(.headline)
			Text("20.09.2025")
				.foregroundStyle(.secondary)
				.font(.caption)
		}
	}
}

#Preview {
	DocumentCell()
		.frame(width: 120, height: 120)
}
