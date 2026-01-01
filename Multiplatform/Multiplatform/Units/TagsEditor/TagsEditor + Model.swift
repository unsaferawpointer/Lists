//
//  TagsEditor + Model.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 01.01.2026.
//

import Foundation
import SwiftData

extension TagsEditor {

	final class Model {
		
	}
}

import SwiftUI

extension TagsEditor.Model {

	func addTag(with name: String, to modelContext: ModelContext, allTags: [Tag]) {
		let newTag = Tag(title: name)
		newTag.index = (allTags.last?.index ?? 0) + 1
		modelContext.insert(newTag)
	}

	func moveTags(_ tags: [Tag], indices: IndexSet, to target: Int) {
		var modificated = tags
		modificated.move(fromOffsets: indices, toOffset: target)
		for (index, tag) in modificated.enumerated() {
			tag.index = index
		}
	}

	func deleteTags(selected: Set<PersistentIdentifier>, in modelContext: ModelContext) {
		for id in selected {
			guard let tag = modelContext.model(for: id) as? Tag else {
				continue
			}
			modelContext.delete(tag)
		}
	}
}
