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
    label.font = .systemFont(ofSize: 12)
    label.textColor = .black
    label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    label.textAlignment = .center
    return label
  }()
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    
    
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
  var pinModel: PlaceAnnotationModel!
  
  init(pinModel: PlaceAnnotationModel) {
    self.pinModel = nil
    self.coordinate = CLLocationCoordinate2D(latitude: pinModel.latitude,
                                             longitude: pinModel.longitude)
  }
  
}
