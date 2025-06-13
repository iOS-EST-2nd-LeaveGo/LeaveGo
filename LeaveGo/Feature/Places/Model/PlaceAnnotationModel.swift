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
    
    let areaCode: String? // 지역코드
    let cat1: String? // 대분류코드
    let cat2: String? // 중분류코드
    let cat3: String? // 소분류코드

    init(coordinate: CLLocationCoordinate2D, title: String?, areaCode: String?, cat1: String?, cat2: String?, cat3: String?) {
        self.coordinate = coordinate
        self.title = title
        self.areaCode = areaCode
        self.cat1 = cat1
        self.cat2 = cat2
        self.cat3 = cat3
    }
}
