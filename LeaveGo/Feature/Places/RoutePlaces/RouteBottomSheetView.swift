//
//  RouteBottomSheetView.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

enum TransportMode: Int {
	case car, walk
}

class RouteBottomSheetView: UIView {
	private let carButton: UIButton = {
		var config = UIButton.Configuration.filled()
		config.image = UIImage(systemName: "car.fill")
		config.imagePadding = 6
		config.baseBackgroundColor = .systemGray5
		config.baseForegroundColor = .label
		
		let btn = UIButton(configuration: config, primaryAction: nil)
		btn.tag = TransportMode.car.rawValue
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	private let walkButton: UIButton = {
		var config = UIButton.Configuration.filled()
		config.image = UIImage(systemName: "figure.walk")
		config.imagePadding = 6
		config.baseBackgroundColor = .systemGray5
		config.baseForegroundColor = .label
		
		let btn = UIButton(configuration: config, primaryAction: nil)
		btn.tag = TransportMode.walk.rawValue
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	private lazy var transportStack: UIStackView = {
		let sv = UIStackView(arrangedSubviews: [carButton, walkButton])
		sv.axis = .horizontal
		sv.distribution = .fillEqually
		sv.spacing = 8
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	let tableView: UITableView = {
		let tv = UITableView(frame: .zero, style: .plain)
		tv.register(RouteStopCell.self,
					forCellReuseIdentifier: RouteStopCell.reuseIdentifier)
		tv.isEditing = true
		tv.allowsSelection = false
		tv.separatorInset = .zero
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()
	
	private(set) var tableHeightConstraint: NSLayoutConstraint!
	
	let addWaypointButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("경유지 추가", for: .normal)
		btn.isHidden = true
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemBackground
		layer.cornerRadius = 12
		layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupLayout() {
		addSubview(transportStack)
		addSubview(tableView)
		//addSubview(addWaypointButton)
		
		tableView.rowHeight = 45
		tableView.estimatedRowHeight = 45
		//tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 56)
		
		NSLayoutConstraint.activate([
			// 1) transportStack
			transportStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			transportStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			transportStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			transportStack.heightAnchor.constraint(equalToConstant: 40),
			
			// 2) tableView
			tableView.topAnchor.constraint(equalTo: transportStack.bottomAnchor, constant: 12),
			tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
			tableHeightConstraint,
			
			// 3) addWaypointButton (사용 안 함)
//			addWaypointButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
//			addWaypointButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//			addWaypointButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
		])
	}
	
	func addTransportTarget(_ target: Any?,
							action: Selector,
							for event: UIControl.Event) {
		carButton.addTarget(target, action: action, for: event)
		walkButton.addTarget(target, action: action, for: event)
	}
	
	// MARK: – 버튼 선택 표시 업데이트
	func select(mode: TransportMode) {
		[carButton, walkButton].forEach { btn in
			btn.configuration?.baseBackgroundColor = (btn.tag == mode.rawValue)
			? .systemBlue.withAlphaComponent(0.2)
			: .systemGray5
		}
	}
}
