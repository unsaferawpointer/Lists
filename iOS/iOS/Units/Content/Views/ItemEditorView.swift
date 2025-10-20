//
//  ItemEditorView.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.10.2025.
//

import UIKit

class ItemEditorView: UIView {

	var action: ((String) -> Void)?

	// MARK: - Data

	var model: ItemEditorModel? {
		didSet {
			configureInterface()
		}
	}

	// MARK: - UI

	lazy var textfield: UITextField = {
		let view = UITextField()
		view.text = "New Item"
		view.placeholder = "Enter text..."
		view.borderStyle = .none
		view.returnKeyType = .done
		view.setContentHuggingPriority(.defaultLow, for: .horizontal)
		view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		return view
	}()

	lazy var button: UIButton = {
		let view = UIButton(type: .system)
		view.setImage(UIImage(systemName: "arrow.up"), for: .normal)
		view.configuration = .prominentGlass()
		view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		let action = UIAction { [weak self] _ in
			guard let self else {
				return
			}
			self.action?(self.textfield.text ?? "")
		}
		view.addAction(action, for: .touchUpInside)
		return view
	}()

	lazy var container: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
		view.cornerConfiguration = UICornerConfiguration.capsule()
		return view
	}()

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)

		configureConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Helpers
private extension ItemEditorView {

	func configureInterface() {
		textfield.text = model?.text
		button.setImage(UIImage(systemName: model?.iconName ?? ""), for: .normal)
		button.isEnabled = !(model?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

		if model?.inFocus == true {
			textfield.becomeFirstResponder()
		}
	}
}

// MARK: - Actions
extension ItemEditorView {

	@objc
	func textFieldDidChange(_ textField: UITextField) {
		guard let text = textField.text else {
			button.isEnabled = false
			return
		}
		button.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}

// MARK: - Helpers
private extension ItemEditorView {

	func configureConstraints() {
		[textfield, button].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			container.contentView.addSubview($0)
		}

		container.translatesAutoresizingMaskIntoConstraints = false
		addSubview(container)

		NSLayoutConstraint.activate(
			[
				textfield.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 16),
				textfield.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 8),
				textfield.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -8),

				button.leadingAnchor.constraint(equalTo: textfield.trailingAnchor, constant: 16),
				button.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -8),
				button.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 8),
				button.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -8)
			]
		)

		NSLayoutConstraint.activate(
			[
				container.leadingAnchor.constraint(equalTo: leadingAnchor),
				container.trailingAnchor.constraint(equalTo: trailingAnchor),
				container.topAnchor.constraint(equalTo: topAnchor),
				container.bottomAnchor.constraint(equalTo: bottomAnchor)
			]
		)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	ItemEditorView(frame: .zero)
}
