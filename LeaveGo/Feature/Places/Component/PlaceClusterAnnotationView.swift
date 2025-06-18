//
//  PlaceClusterAnnotationView.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/17/25.
//

import MapKit

final class PlaceClusterAnnotationView: MKAnnotationView {
	static let identifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
	
	// MARK: - Subviews
	private let circleView: UIView = {
		let v = UIView()
		v.backgroundColor = .systemPink
		v.layer.borderColor = UIColor.white.cgColor
		v.layer.borderWidth = 2
		return v
	}()
	private let symbolView: UIImageView = {
		let iv = UIImageView()
		iv.tintColor = .white
		iv.contentMode = .scaleAspectFit
		return iv
	}()
	
	private let countLabel: StrokedLabel = {
		let lbl = StrokedLabel()
		lbl.font = .systemFont(ofSize: 13, weight: .medium)
		lbl.textColor = .black
		lbl.textAlignment = .center
		lbl.strokeWidth = 3.0
		lbl.strokeColor = .white
	
		lbl.textColor   = .black
		return lbl
	}()
	
	// MARK: - Init
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Layout
	private func setupUI() {
		let diameter: CGFloat = 50
		let labelHeight: CGFloat = 8
		let spacing: CGFloat = 16
		frame = CGRect(x: 0, y: 0, width: diameter, height: diameter + spacing + labelHeight)

		frame = CGRect(x: 0, y: 0,
					   width: diameter,
					   height: diameter + spacing + labelHeight)
		
		// 2) 배경 원
		circleView.frame = CGRect(origin: .zero,
								  size: CGSize(width: diameter,
											   height: diameter))
		circleView.layer.cornerRadius = diameter / 2
		circleView.center.x = bounds.midX
		addSubview(circleView)
		
		// 3) 심볼 아이콘 (32×32)
		let symbolSize: CGFloat = 32
		symbolView.frame = CGRect(
			x: (diameter - symbolSize) / 2,
			y: (diameter - symbolSize) / 2,
			width: symbolSize,
			height: symbolSize
		)
		circleView.addSubview(symbolView)
		
		// 4) 카운트 레이블
		countLabel.frame = CGRect(
			x: 0,
			y: diameter + spacing,
			width: diameter,
			height: labelHeight
		)
		addSubview(countLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	// MARK: - Configure
	func configure(with cat1: String?, count: Int) {

		let name = sfSymbolName(for: cat1)
		symbolView.image = UIImage(systemName: name)

		let text = "\(count)"
		let attrs: [NSAttributedString.Key: Any] = [
			.font: UIFont.boldSystemFont(ofSize: 12),
			.foregroundColor: UIColor.black,
			.strokeColor: UIColor.white,
			.strokeWidth: -2.0
		]
		countLabel.attributedText = NSAttributedString(string: text, attributes: attrs)
	}
	
	// MARK: - SF Symbol Mapping
	private func sfSymbolName(for cat1: String?) -> String {
		switch cat1 {
		case "A01": return "leaf.fill"
		case "A02": return "paintpalette.fill"
		case "A03": return "figure.wave"
		case "A04": return "bag.fill"
		case "A05": return "fork.knife"
		case "A06": return "bed.double.fill"
		case "A07": return "tram.fill"
		case "A08": return "location.viewfinder"
		case "A09": return "sparkles"
		case "A10": return "sportscourt.fill"
		case "B01": return "building.columns.fill"
		case "C01": return "museum.fill"
		default:    return "mappin.circle.fill"
		}
	}
}
