//
//  MasterView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI
import SwiftData

struct MasterView: View {

	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Project.creationDate, order: .forward, animation: .default) private var projects: [Project]

	var body: some View {
		List {
			Label("All", systemImage: "square.grid.2x2")
			NavigationLink {
				TagsEditor()
			} label: {
				Label("Tags", systemImage: "tag")
			}
			Section("Projects") {
				ForEach(projects) { project in
					NavigationLink {
						ContentView()
					} label: {
						Label(project.name, systemImage: project.icon.systemName)
					}
				}
			}
		}
		.listStyle(.sidebar)
		.navigationTitle("Lists")
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					addProject()
				} label: {
					Label("Add Item", systemImage: "plus")
				}
			}
		}
	}
}

// MARK: - Helpers
private extension MasterView {

	func addProject() {
		withAnimation {
			let newProject = Project(name: "Default Project", icon: .star)
			modelContext.insert(newProject)
		}
	}
}

#Preview {
	MasterView()
}
