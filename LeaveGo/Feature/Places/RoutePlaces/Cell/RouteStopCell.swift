//
//  RouteStopCell.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class RouteStopCell: UITableViewCell {
	static let reuseIdentifier = "RouteStopCell"
	
	private let timelineView: TimelineView = {
		let v = TimelineView()
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	lazy var iconView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	lazy var titleLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .systemFont(ofSize: 16, weight: .regular)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()
	
//	private let lineLayer: CAShapeLayer = {
//		let layer = CAShapeLayer()
//		layer.strokeColor = UIColor.systemGray3.cgColor
//		layer.lineWidth = 1
//		layer.lineDashPattern = [2, 4]
//		return layer
//	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupCell()
		setupLayout()
		
		//contentView.layer.insertSublayer(lineLayer, at: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupCell() {
		// 편집 모드에서 이동 컨트롤 표시
		showsReorderControl = true
		editingAccessoryType = .none
		shouldIndentWhileEditing = false
		selectionStyle = .none
	}
	
	private func setupLayout() {
		contentView.addSubview(timelineView)
		contentView.addSubview(iconView)
		contentView.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			timelineView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
			// 셀의 맨 위에서 맨 아래까지 점선 연결
			timelineView.topAnchor.constraint(equalTo: contentView.topAnchor),
			timelineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			timelineView.widthAnchor.constraint(equalToConstant: 1),
			// 아이콘
			iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			iconView.widthAnchor.constraint(equalToConstant: 24),
			iconView.heightAnchor.constraint(equalToConstant: 24),
			
			// 제목
			titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12)
		])
	}
	
	func configure(with stop: Stop, isFirst: Bool, isLast: Bool) {
		// 1) 라벨 텍스트
		titleLabel.text = stop.name
		
		// 2) 원형 배경 + icon
		iconView.backgroundColor = stop.color
		iconView.image = UIImage(systemName: stop.iconName)?
			.withRenderingMode(.alwaysTemplate)
		iconView.tintColor = .white
		
		// 3) 타임라인 연결 표시
		// 첫 번째 셀은 위쪽 연결선을 숨기고,
		// 마지막 셀은 아래쪽 연결선을 숨깁니다.
		timelineView.showTopConnector = !isFirst
		timelineView.showBottomConnector = !isLast
		timelineView.setNeedsDisplay()
	}
}

private class TimelineView: UIView {
	/// 위쪽 선 표시 여부
	var showTopConnector: Bool = true
	/// 아래쪽 선 표시 여부
	var showBottomConnector: Bool = true
	
	override func draw(_ rect: CGRect) {
		guard let ctx = UIGraphicsGetCurrentContext() else { return }
		ctx.setLineWidth(1)
		ctx.setStrokeColor(UIColor.systemGray4.cgColor)
		// [4pt 그리기, 4pt 띄우기] 형태의 점선
		ctx.setLineDash(phase: 0, lengths: [4, 4])
		
		let centerX = rect.width / 2      // 아이콘 X 중심과 일치
		let midY = bounds.height / 2
		let radius = 12.0                // iconView 반지름
		
		// 위쪽 연결선
		if showTopConnector {
			ctx.move(to: CGPoint(x: centerX, y: 0))
			ctx.addLine(to: CGPoint(x: centerX, y: midY - CGFloat(radius)))
			ctx.strokePath()
		}
		// 아래쪽 연결선
		if showBottomConnector {
			ctx.move(to: CGPoint(x: centerX, y: midY + CGFloat(radius)))
			ctx.addLine(to: CGPoint(x: centerX, y: rect.height))
			ctx.strokePath()
		}
	}
}
