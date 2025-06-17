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
	private let countLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .boldSystemFont(ofSize: 12)
		lbl.textColor = .black
		lbl.textAlignment = .center
		// 흰색 stroke
		lbl.attributedText = NSAttributedString(string: "0", attributes: [
			.strokeColor: UIColor.white,
			.strokeWidth: 1
		])
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
		let diameter: CGFloat = 30
		let labelHeight: CGFloat = 14
		let spacing: CGFloat = 8
		frame = CGRect(x: 0, y: 0, width: diameter, height: diameter + spacing + labelHeight)

		circleView.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		circleView.layer.cornerRadius = diameter / 2
		circleView.center.x = bounds.midX
		addSubview(circleView)

		symbolView.frame = circleView.bounds.insetBy(dx: diameter * 0.1,
													 dy: diameter * 0.1)
		symbolView.center = CGPoint(x: diameter/2, y: diameter/2)
		circleView.addSubview(symbolView)

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

