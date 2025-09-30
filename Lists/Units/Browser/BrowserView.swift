//
//  BrowserView.swift
//  Lists
//
//  Created by Anton Cherkasov on 18.09.2025.
//

import SwiftData
import SwiftUI

struct BrowserView: View {

	@Environment(\.modelContext) private var modelContext
	@Query(animation: .default) private var documents: [DocumentEntity]

	@State var presentedDocument: DocumentItem? = nil

	@State var selection: Set<UUID> = []

	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns:
					[
						.init(.flexible(), spacing: 24),
						.init(.flexible(), spacing: 24)
					]
			) {
				Button {

				} label: {
					ActionCell()
						.aspectRatio(1, contentMode: .fit)
				}
				ForEach(documents) { document in
					DocumentCell()
						.aspectRatio(1, contentMode: .fit)
					.contextMenu {
						Button {

						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
				}
			}
		}
		.scrollIndicators(.hidden)
		.contentMargins(24)
		.navigationTitle("Documents")
		.navigationDestination(for: UUID.self) { id in
			DocumentView()
		}
		.sheet(item: $presentedDocument) { document in
			DocumentDetailsView(document: document)
		}
		.toolbar {
			buildToolbar()
		}
	}
}

// MARK: - Helpers
private extension BrowserView {

	#if os(iOS)
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		ToolbarItem(placement: .bottomBar) {
			Spacer()
		}
		ToolbarItem(placement: .bottomBar) {
			Button {
				addItem()
			} label: {
				Label("Add Item", systemImage: "plus")
			}
		}
	}
	#elseif os(macOS)
	@ToolbarContentBuilder
	func buildToolbar() -> some ToolbarContent {
		ToolbarItem {
			Spacer()
		}
		ToolbarItem(placement: .primaryAction) {
			Button {
				presentedDocument = .init(name: "New Document", iconName: "doc.text")
			} label: {
				Label("Add Item", systemImage: "plus")
			}
		}
	}
	#endif
}

// MARK: - Helpers
private extension BrowserView {

	func addItem() {
		withAnimation {
			let newItem = DocumentEntity(name: "New Document")
			modelContext.insert(newItem)
		}
	}

	func delete(ids: Set<UUID>) {
		withAnimation {
			let models = documents.filter { ids.contains($0.uuid) }
			for model in models {
				modelContext.delete(model)
			}
		}
	}
}

#Preview {
	NavigationStack {
		BrowserView()
	}
}

struct BeautifulDocumentCell: View {

	var body: some View {
		VStack(alignment: .center) {
			Image(systemName: "doc.text")
				.resizable()
				.foregroundStyle(.tertiary)
				.aspectRatio(contentMode: .fill)
				.padding()
				.glassEffect(.regular.tint(.secondary.opacity(0.1)), in: RoundedRectangle(cornerRadius: 24))
			Text("Sprint 2 - 6 June")
				.foregroundStyle(.primary)
				.font(.body)
			Text("23.09.2025")
				.foregroundStyle(.secondary)
				.font(.callout)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
