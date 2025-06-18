//
//  PlaceAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import MapKit

final class PlaceAnnotationView: MKAnnotationView {
	static let identifier: String = "PlaceAnnotationView"
	static let clusterIdentifier: String = "placeCluster"
	
    let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.borderWidth = 2
		imageView.layer.borderColor = UIColor.white.cgColor
		imageView.backgroundColor = .white
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .black)
		label.textColor = .label
        label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.7
		label.lineBreakMode = .byClipping
		return label
	}()
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		frame = CGRect(x: 0, y: 0, width: 64, height: 64)

		configureSubviews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		imageView.layer.cornerRadius = 25
		
		let spacing: CGFloat = 4

		titleLabel.frame = CGRect(
			x: 0,
			y: imageView.frame.maxY + spacing,
			width: bounds.width,
			height: 14
		)
	}
	
	func configure(with annotation: PlaceAnnotationModel) {
		titleLabel.text = annotation.title
		
		clusteringIdentifier = Self.clusterIdentifier
		
		if let thumbnailImage = annotation.thumbnailImage {
			imageView.image = thumbnailImage
		} else {
			let size = CGSize(width: 120, height: 120)
			UIGraphicsBeginImageContext(size)
            if let image = UIImage(named: "Image") {
				image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
				if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
					imageView.image = resizedImage
				}
			}
			
			UIGraphicsEndImageContext()
		}
	}
}

// MARK: LayoutSupport
extension PlaceAnnotationView: LayoutSupport {
	
	func addSubviews() {
		addSubview(imageView)
		addSubview(titleLabel)
	}
	
	func setupSubviewsConstraints() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: topAnchor),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.widthAnchor.constraint(equalToConstant: 40),
			imageView.heightAnchor.constraint(equalToConstant: 40),
			
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.heightAnchor.constraint(equalToConstant: 20)
		])
	}
}
