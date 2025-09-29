//
//  DocumentRow.swift
//  Lists
//
//  Created by Anton Cherkasov on 29.09.2025.
//

import SwiftUI

struct DocumentRow: View {

	@State var document: DocumentRowModel

	var body: some View {
		Label(document.title, systemImage: document.iconName)
	}
}

#Preview {
	List {
		DocumentRow(document: .init(title: "Document", iconName: "doc.text"))
			.listItemTint(.monochrome)
		DocumentRow(document: .init(title: "Document", iconName: "rectangle.split.3x1"))
			.listItemTint(.secondary)
		DocumentRow(document: .init(title: "Document", iconName: "doc.text"))
			.listItemTint(.yellow)
			.environment(\.layoutDirection, .rightToLeft)
	}
}
