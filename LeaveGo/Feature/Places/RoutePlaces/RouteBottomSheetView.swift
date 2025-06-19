//
//  RouteBottomSheetView.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class RouteBottomSheetView: UIView {
	/// 차, 도보, 대중교통 모드
	enum TransportMode: Int {
		case car, walk, transit
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
	
	let transitButton: UIButton = {
		let btn = UIButton(type: .system)
		var cfg = UIButton.Configuration.filled()
		cfg.image = UIImage(systemName: "tram.fill")
		cfg.baseBackgroundColor = .systemGray5
		cfg.baseForegroundColor = .label
		btn.configuration = cfg
		btn.tag = TransportMode.transit.rawValue
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	let emptyStateLabel: UILabel = {
		let lbl = UILabel()
		lbl.text = ""
		lbl.textColor = .secondaryLabel
		lbl.font = .systemFont(ofSize: 14)
		lbl.textAlignment = .center
		lbl.numberOfLines = 0
		lbl.isHidden = true
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
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

	let startDestinationTableView: UITableView = {
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
		backgroundColor = UIColor { tc in
			tc.userInterfaceStyle == .dark
			? .black
			: .white
		}
		addSubview(topStack)
		topStack.addArrangedSubview(carButton)
		topStack.addArrangedSubview(transitButton)
		topStack.addArrangedSubview(walkButton)
		addSubview(startDestinationTableView)
		addSubview(emptyStateLabel)

		NSLayoutConstraint.activate([
			topStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
			topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
			topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
			topStack.heightAnchor.constraint(equalToConstant: 44),
		])

		NSLayoutConstraint.activate([
			startDestinationTableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 16),
			startDestinationTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			startDestinationTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
		])
		
		NSLayoutConstraint.activate([
			emptyStateLabel.topAnchor.constraint(equalTo: startDestinationTableView.bottomAnchor, constant: 16),
			emptyStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			emptyStateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
		])

		
		tableHeightConstraint = startDestinationTableView.heightAnchor.constraint(equalToConstant: 0)
		tableHeightConstraint.isActive = true
	}

	func addTransportTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
		carButton.addTarget(target, action: action, for: event)
		walkButton.addTarget(target, action: action, for: event)
		transitButton.addTarget(target, action: action, for: event)
	}
	
	func select(mode: TransportMode) {
		let bg = UIColor { tc in
			tc.userInterfaceStyle == .dark ? .white : .systemGray5
		}
		let fg = UIColor.black
		let border = UIColor.black
		
		for btn in [carButton, walkButton, transitButton] {
			guard var cfg = btn.configuration else { continue }
			cfg.baseBackgroundColor = bg
			cfg.baseForegroundColor = fg
			
			if btn.tag == mode.rawValue {
				cfg.background.strokeColor = border
				cfg.background.strokeWidth = 1
			} else {
				cfg.background.strokeColor = .clear
				cfg.background.strokeWidth = 0
			}
			
			btn.configuration = cfg
		}
	}
}
