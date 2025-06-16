//
//  PlaceAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import MapKit

final class PlaceAnnotationView: MKAnnotationView {
    
    static let identifier: String = "PlaceAnnotationView"
    
    private let imageView: UIImageView = {
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
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 60)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    func configure(with annotation: PlaceAnnotationModel) {
        titleLabel.text = annotation.title
        
        // 클러스터링 식별자 설정
        // clusteringIdentifier = "\(annotation.areaCode ?? "1")-\(annotation.cat1 ?? "1")"
        
        if let thumbnailImage = annotation.thumbnailImage {
            imageView.image = thumbnailImage
        } else {
            // 기본 이미지 설정
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContext(size)
            
            if let image = UIImage(systemName: "pin.circle.fill") {
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
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
