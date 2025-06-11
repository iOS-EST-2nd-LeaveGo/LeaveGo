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
	let carButton: UIButton = {
		let btn = UIButton(type: .system)
		var cfg = UIButton.Configuration.filled()
		cfg.image = UIImage(systemName: "car.fill")
		cfg.baseBackgroundColor = .systemGray5
		cfg.baseForegroundColor = .label
		btn.configuration = cfg
		btn.tag = TransportMode.car.rawValue
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()

	let walkButton: UIButton = {
		let btn = UIButton(type: .system)
		var cfg = UIButton.Configuration.filled()
		cfg.image = UIImage(systemName: "figure.walk")
		cfg.baseBackgroundColor = .systemGray5
		cfg.baseForegroundColor = .label
		btn.configuration = cfg
		btn.tag = TransportMode.walk.rawValue
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()

	let topStack: UIStackView = {
		let stack = UIStackView()
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
		topStack.addArrangedSubview(carButton)
		topStack.addArrangedSubview(walkButton)
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

//	func addTransportTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
//		for view in topStack.arrangedSubviews {
//			if let btn = view as? UIButton {
//				btn.addTarget(target, action: action, for: event)
//			}
//		}
//	}
	
	func addTransportTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
		carButton.addTarget(target, action: action, for: event)
		walkButton.addTarget(target, action: action, for: event)
	}
	
	func select(mode: TransportMode) {
		for btn in [carButton, walkButton] {
			btn.configuration?.baseBackgroundColor =
				(btn.tag == mode.rawValue)
				? UIColor.systemBlue.withAlphaComponent(0.3)
				: .systemGray5
		}
	}
}


