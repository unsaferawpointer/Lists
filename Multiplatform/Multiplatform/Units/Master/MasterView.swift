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

	// MARK: - Project Support

	@Query(sort: \Project.creationDate, order: .forward, animation: .default) private var projects: [Project]

	@State var presentedProject: Project?
	@State var projectEditorIsPresented: Bool = false

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
					.contextMenu {
						Button {
							self.presentedProject = project
						} label: {
							Label("Edit...", systemImage: "pencil")
						}
						Divider()
						Button(role: .destructive) {
							deleteProject(project: project)
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
				}
			}
		}
		.listStyle(.sidebar)
		.navigationTitle("Lists")
		.sheet(isPresented: $projectEditorIsPresented) {
			TagEditor(title: "New Project", model: .init(name: "")) { newModel in
				withAnimation {
					let newProject = Project(name: newModel.name)
					modelContext.insert(newProject)
				}
			}
		}
		.sheet(item: $presentedProject) { project in
			TagEditor(title: "Edit Tag", model: .init(name: project.name)) { newModel in
				project.name = newModel.name
			}
		}
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
			self.projectEditorIsPresented = true
		}
	}

	func deleteProject(project: Project) {
		withAnimation {
			modelContext.delete(project)
		}
	}
}

#Preview {
	MasterView()
}
