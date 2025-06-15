//
//  PlaceAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import MapKit

final class PlaceAnnotationView: MKAnnotationView {
    
    static let identifier: String = "PlaceAnnotationView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .black)
        label.textColor = .label // TODO: change accentColor
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    let imageView = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.frame = bounds
        imageView.layer.cornerRadius = bounds.height / 2
    }
    
    func configure(with place: PlaceAnnotationModel) {
        imageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.layer.cornerRadius = 15
        clusteringIdentifier = "\(String(describing: place.areaCode ?? "1"))-\(String(describing: place.cat1 ?? "A02"))"
        
        titleLabel.text = place.title
    }
}

// MARK: LayoutSupport
extension PlaceAnnotationView: LayoutSupport {
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(imageView)
    }
    
    func setupSubviewsConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
}
