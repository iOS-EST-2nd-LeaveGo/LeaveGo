//
//  PlaceAnnotationModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

import MapKit

class PlaceAnnotationModel: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    let thumbnailImage: UIImage?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String? = nil, thumbnailImage: UIImage?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.thumbnailImage = thumbnailImage
    }
}
