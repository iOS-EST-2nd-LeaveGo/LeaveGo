//
//  RouteStopCell.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

/// PlaceRouteBottomSheetView - UIcomponents
/// 경로 검색 바텀 시트 뷰 - 출발지, 목적지 UI
class RouteStopCell: UITableViewCell {
	static let reuseIdentifier = "RouteStopCell"
	
	// MARK: Subviews
	lazy var container: UIView = {
		let v = UIView()
		v.backgroundColor = .systemGray6
		v.layer.cornerRadius = 10
		v.layer.masksToBounds = true
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	private let nameLabel: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.font = .systemFont(ofSize: 17)
		lbl.textColor = .label
		return lbl
	}()

	let iconBackgroundView: UIView = {
		let v = UIView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 20
		v.clipsToBounds = true
		return v
	}()

	let iconImageView: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFit
		iv.tintColor = .white
		return iv
	}()
	
	override init(style: UITableViewCell.CellStyle,
				  reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayout()
	}
	
	// MARK: Layout
	
	private func setupLayout() {
		backgroundColor = .clear
		selectionStyle = .none
		
		insertSubview(container, at: 0)
		
		container.addSubview(iconBackgroundView)
		container.addSubview(nameLabel)
		iconBackgroundView.addSubview(iconImageView)
		
		NSLayoutConstraint.activate([
			container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			container.topAnchor.constraint(equalTo: topAnchor),
			container.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
			iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
			iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),
			
			iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
			iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 24),
			iconImageView.heightAnchor.constraint(equalToConstant: 24),
			
			nameLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 32),
			nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -32),
			nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
		])
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	// MARK: Helpers
	private var isFirstCell: Bool {
		
		return false
	}
	
	private var isLastCell: Bool {
		return false
	}
	
	// MARK: Configuration
	func configure(with stop: Stop, isFirst: Bool, isLast: Bool) {
		iconImageView.image = UIImage(systemName: stop.iconName)
		iconBackgroundView.backgroundColor = stop.color
		nameLabel.text = stop.name
		nameLabel.font = .systemFont(ofSize: 17)
	}
}

