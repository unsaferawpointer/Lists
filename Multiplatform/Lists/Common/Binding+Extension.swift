//
//  Binding+Extension.swift
//  Lists
//
//  Created by Anton Cherkasov on 05.10.2025.
//

import SwiftUI

extension Binding {

	init (_ value: Binding<Value?>, default: Value) {
		self.init {
			value.wrappedValue ?? `default`
		} set: { newValue in
			value.wrappedValue = newValue
		}
	}
}
