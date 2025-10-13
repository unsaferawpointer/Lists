//
//  ListsApp.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI
import SwiftData

@main
struct ListsApp: App {
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			ItemEntity.self,
			ListEntity.self
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			NavigationSplitView {
				SidebarView()
			} detail: {
				ContentView(list: nil)
			}
		}
		.modelContainer(sharedModelContainer)
	}
}
