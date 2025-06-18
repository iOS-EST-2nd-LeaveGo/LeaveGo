//
//  RouteOptionsCell.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/16/25.
//

import Foundation
import UIKit
import MapKit

class RouteOptionsCell: UITableViewCell {
	static let reuseIdentifier = "RouteOptionsCell"
	
	private let timeLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .systemFont(ofSize: 16, weight: .semibold)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private let distanceLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .systemFont(ofSize: 14)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
	private let tollIcon: UIImageView = {
		let iv = UIImageView(image: UIImage(systemName: "wonsign.circle.fill"))
		iv.tintColor = .systemGreen
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	private let navigateButton: UIButton = {
		var config = UIButton.Configuration.filled()
		config.title = "길 안내"
		
		// 1) 애플 로고 추가
		config.image = UIImage(systemName: "apple.logo")
		config.imagePlacement = .leading
		config.imagePadding = 4
		
		// 2) 기존 색상 & 스타일 유지
		config.baseBackgroundColor = UIColor { tc in
			tc.userInterfaceStyle == .dark ? .white : .black
		}
		config.baseForegroundColor = UIColor { tc in
			tc.userInterfaceStyle == .dark ? .black : .white
		}
		config.cornerStyle = .dynamic
		
		let btn = UIButton(configuration: config)
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	private lazy var hStack: UIStackView = {
		let sv = UIStackView(arrangedSubviews: [
			timeLabel, distanceLabel, tollIcon, UIView(), navigateButton
		])
		sv.axis = .horizontal
		sv.alignment = .center
		sv.spacing = 8
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupLayout() {
		contentView.addSubview(hStack)
		NSLayoutConstraint.activate([
			hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
	}
	
	// MARK: – Configure
	func configure(
		with route: MKRoute,
		at index: Int,
		target: Any?,
		action: Selector
	) {
		timeLabel.text     = route.expectedTravelTime.timeString
		distanceLabel.text = route.distance.distanceString
		if #available(iOS 16.0, *) {
			tollIcon.isHidden = !route.hasTolls
		} else {
			tollIcon.isHidden = true
		}
		
		navigateButton.tag = index
		navigateButton.removeTarget(nil, action: nil, for: .allEvents)
		navigateButton.addTarget(target, action: action, for: .touchUpInside)
	}
}
