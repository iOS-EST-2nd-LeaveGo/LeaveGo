//
//  RouteBottomSheetView.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class RouteBottomSheetView: UIView {
	/// 차, 도보 모드
	enum TransportMode: Int {
		case car, walk
	}

	// MARK: – Subviews

	let topStack: UIStackView = {
		let carButton = UIButton(type: .system)
		var carConfig = UIButton.Configuration.filled()
		carConfig.image = UIImage(systemName: "car.fill")
		carConfig.baseBackgroundColor = .systemGray5
		carConfig.baseForegroundColor = .label
		carButton.configuration = carConfig
		carButton.tag = TransportMode.car.rawValue

		let walkButton = UIButton(type: .system)
		var walkConfig = UIButton.Configuration.filled()
		walkConfig.image = UIImage(systemName: "figure.walk")
		walkConfig.baseBackgroundColor = .systemGray5
		walkConfig.baseForegroundColor = .label
		walkButton.configuration = walkConfig
		walkButton.tag = TransportMode.walk.rawValue

		let stack = UIStackView(arrangedSubviews: [carButton, walkButton])
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	let closeButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setImage(UIImage(systemName: "xmark"), for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()

	let tableView: UITableView = {
		let tv = UITableView()
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()

	private(set) var tableHeightConstraint: NSLayoutConstraint!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayout()
	}

	// MARK: – Layout

	private func setupLayout() {
		backgroundColor = .white
		addSubview(topStack)
		addSubview(closeButton)
		addSubview(tableView)

		NSLayoutConstraint.activate([
			topStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
			topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -56),
			topStack.heightAnchor.constraint(equalToConstant: 44),
		])

		NSLayoutConstraint.activate([
			closeButton.centerYAnchor.constraint(equalTo: topStack.centerYAnchor),
			closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			closeButton.widthAnchor.constraint(equalToConstant: 24),
			closeButton.heightAnchor.constraint(equalToConstant: 24),
		])

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 16),
			tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
		])
		
		tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
		tableHeightConstraint.isActive = true
	}

	func addTransportTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
		for view in topStack.arrangedSubviews {
			if let btn = view as? UIButton {
				btn.addTarget(target, action: action, for: event)
			}
		}
	}
	
	func select(mode: TransportMode) {
		for view in topStack.arrangedSubviews {
			guard let btn = view as? UIButton else { continue }
			if btn.tag == mode.rawValue {
				btn.configuration?.baseBackgroundColor = .systemBlue.withAlphaComponent(0.3)
			} else {
				btn.configuration?.baseBackgroundColor = .systemGray5
			}
		}
	}
}


