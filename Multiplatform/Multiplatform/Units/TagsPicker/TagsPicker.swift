//
//  TagsPicker.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 28.12.2025.
//

import SwiftUI
import SwiftData

struct TagsPicker: View {

	@Environment(\.dismiss) var dismiss

	@Environment(\.modelContext) private var modelContext
	@Query private var tags: [Tag]

	@State var selection: Set<PersistentIdentifier>

	let completion: (Set<PersistentIdentifier>) -> Void

	// MARK: - Initialization

	init(selected: Set<PersistentIdentifier>, completion: @escaping (Set<PersistentIdentifier>) -> Void) {
		self._selection = State(initialValue: selected)
		self.completion = completion
	}

	var body: some View {
		NavigationStack {
			List {
				ForEach(tags, id: \.uuid) { tag in
					Button {
						if selection.contains(tag.id) {
							selection.remove(tag.id)
						} else {
							selection.insert(tag.id)
						}
					} label: {
						HStack {
							Label(tag.title, systemImage: "tag")
							Spacer()
							if selection.contains(tag.id) {
								Image(systemName: "checkmark")
							}
						}
						.listItemTint(.primary)
					}
				}
			}
			.listStyle(.inset)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .close) {
						dismiss()
					}
				}
				ToolbarItem(placement: .bottomBar) {
					Spacer()
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						completion(selection)
						dismiss()
					}
				}
			}
		}
	}
}

#Preview {
	TagsPicker(selected: []) { _ in }
		.modelContainer(for: Tag.self, inMemory: true)
}
