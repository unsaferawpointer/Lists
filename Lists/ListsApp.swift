//
//  ListsApp.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftUI
import SwiftData

@main
struct ListsApp: App {
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			DocumentEntity.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			NavigationSplitView {
				BrowserView()
					.modelContainer(sharedModelContainer)
			} detail: {
				Text("Empty")
			}
		}
	}
}
