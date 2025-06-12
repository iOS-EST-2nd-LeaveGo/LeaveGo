//
//  PlaceModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/12/25.
//

import CoreLocation
import UIKit

struct PlaceModel {
    let contentId: String // 장소 고유번호
    let title: String // 장소명(use in PlacesVC)
    let thumbnailURL: String?
    var thumbnailImage: UIImage? // 썸네일 이미지(use in PlacesVC)
    let distance: String // 거리(use in PlacesVC)
    let latitude: Double // (use in PlacesVC)
    let longitude: Double // (use in PlacesVC)
    
    let detail: PlaceDetailModel?
    
    init(contentId: String, title: String, thumbnailURL: String?, distance: String, latitude: String?, longitude: String?, detail: PlaceDetailModel?) {
        self.contentId = contentId
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.distance = distance
        self.latitude = Double(latitude!) ?? 0.0
        self.longitude = Double(longitude!) ?? 0.0
        self.detail = detail
    }
    
}

extension PlaceModel {
    
    /// MapViewContoller에서 mapview에 전달 하기위해 annotaionModel형태로 전달해야 합니다.
    func toAnnotationModel() -> PlaceAnnotationModel {
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                             title: title)
    }
    
}

struct PlaceDetailModel {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let infoCenter: String? // 안내센터명 또는 전화번호
    let openTime: String? // 운영시간
}
