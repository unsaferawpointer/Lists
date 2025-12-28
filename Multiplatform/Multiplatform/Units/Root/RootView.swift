//
//  RootView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI
import SwiftData

struct RootView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var items: [Item]

	var body: some View {
		NavigationSplitView {
			MasterView()
		} detail: {
			Text("Select an item")
		}
	}
}

#Preview {
	RootView()
		.modelContainer(for: Item.self, inMemory: true)
}
