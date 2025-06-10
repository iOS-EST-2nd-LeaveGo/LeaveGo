//
//  PlaceAnnotationView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import MapKit
import UIKit

final class PlaceAnnotationView: MKAnnotationView {
  
  static let identifier: String = "PlaceAnnotationView"
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.textColor = .black
    label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    label.textAlignment = .center
    return label
  }()
  
  func setupUI() {
    image = UIImage(systemName: "pin.circle.fill")
    if image != nil {
      let size = CGSize(width: 40, height: 40)
      image!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    image = resizedImage
    
    addSubview(titleLabel)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 2),
      titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
      titleLabel.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
}

// annotation model
class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
