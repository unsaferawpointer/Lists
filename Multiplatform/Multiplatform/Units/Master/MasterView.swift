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
	@Query(animation: .default) private var filters: [Filter]

	@State var presentedProject: Project?
	@State var projectEditorIsPresented: Bool = false

	@State var presentedFilter: Filter?
	@State var filterEditorIsPresented: Bool = false

	var body: some View {
		List {
			NavigationLink {
				ContentView(predicate: .all)
			} label: {
				Label("All", systemImage: "square.grid.2x2")
			}
			NavigationLink {
				TagsEditor()
			} label: {
				Label("Tags", systemImage: "tag")
			}
			buildFiltersSection()
			buildProjectsSection()
		}
		.listStyle(.sidebar)
		.navigationTitle("Lists")
		.sheet(isPresented: $projectEditorIsPresented) {
			ProjectEditor(title: "New Project", model: .init(name: "")) { newModel in
				withAnimation {
					let newProject = Project(name: newModel.name)
					modelContext.insert(newProject)
				}
			}
		}
		.sheet(item: $presentedProject) { project in
			ProjectEditor(title: "Edit Project", model: .init(name: project.name)) { newModel in
				project.name = newModel.name
			}
		}
		.sheet(isPresented: $filterEditorIsPresented) {
			FilterEditor(title: "New Filter", model: .init(name: "", icon: .none, matchType: .any, tags: [])) { newModel in
				withAnimation {
					let newFilter = Filter(title: newModel.name)
					newFilter.matchType = newModel.matchType
					newFilter.icon = newModel.icon
					let tags = newModel.tags.compactMap { id -> Tag? in
						guard let tag = modelContext.model(for: id) as? Tag else {
							return nil
						}
						return tag
					}
					newFilter.tags = tags
					modelContext.insert(newFilter)
				}
			}
		}
		.sheet(item: $presentedFilter) { filter in
			FilterEditor(
				title: "Edit Filter",
				model: .init(
					name: filter.title,
					icon: filter.icon,
					matchType: filter.matchType,
					tags: Set(filter.tags.map(\.id))
				)
			) { newModel in
				withAnimation {
					filter.title = newModel.name
					filter.matchType = newModel.matchType
					filter.icon = newModel.icon
					let tags = newModel.tags.compactMap { id -> Tag? in
						guard let tag = modelContext.model(for: id) as? Tag else {
							return nil
						}
						return tag
					}
					filter.tags = tags
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Menu("", systemImage: "plus") {
					Button {
						addProject()
					} label: {
						Label("New Project", systemImage: "list.bullet")
					}
					Button {
						addFilter()
					} label: {
						Label("New Filter", systemImage: "line.3.horizontal.decrease")
					}
				}
			}
		}
	}
}

// MARK: - View Builders
private extension MasterView {

	@ViewBuilder
	func buildFiltersSection() -> some View {
		if !filters.isEmpty {
			Section("Filters") {
				ForEach(filters) { filter in
					NavigationLink {
						ContentView(
							predicate: .filter(
								tags: Set(filter.tags.map(\.uuid)),
								matchType: filter.matchType
							)
						)
					} label: {
						Label(filter.title, systemImage: filter.icon != .none ? filter.icon.systemName : "line.3.horizontal.decrease")
					}
					.contextMenu {
						Button {
							self.presentedFilter = filter
						} label: {
							Label("Edit...", systemImage: "pencil")
						}
						Divider()
						Button(role: .destructive) {
							deleteFilter(filter: filter)
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
				}
			}
		}
	}

	@ViewBuilder
	func buildProjectsSection() -> some View {
		if !projects.isEmpty {
			Section("Projects") {
				ForEach(projects) { project in
					NavigationLink {
						ContentView(predicate: .inProject(id: project.id))
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
	}
}

// MARK: - Helpers
private extension MasterView {

	func addProject() {
		withAnimation {
			self.projectEditorIsPresented = true
		}
	}

	func addFilter() {
		withAnimation {
			self.filterEditorIsPresented = true
		}
	}

	func deleteProject(project: Project) {
		withAnimation {
			modelContext.delete(project)
		}
	}

	func deleteFilter(filter: Filter) {
		withAnimation {
			modelContext.delete(filter)
		}
	}
}

#Preview {
	MasterView()
}
