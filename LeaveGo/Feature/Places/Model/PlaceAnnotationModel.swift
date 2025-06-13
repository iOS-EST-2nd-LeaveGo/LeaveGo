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

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
