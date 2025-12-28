//
//  MasterView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI

struct MasterView: View {

	@State var isExpanded: Bool = true

	var body: some View {
		List {
			Label("All", systemImage: "square.grid.2x2")
			NavigationLink {
				TagsEditor()
			} label: {
				Label("Tags", systemImage: "tag")
			}
			Section("Filters") {
				ForEach(0..<7) { _ in
					NavigationLink {
						ContentView()
					} label: {
						Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
					}
				}
			}
		}
		.listStyle(.sidebar)
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button(action: { }) {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	MasterView()
}
