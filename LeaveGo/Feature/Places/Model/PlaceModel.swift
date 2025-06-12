//
//  PlaceModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/12/25.
//

import Foundation

struct PlaceModel {
    let contentId: String // 장소 고유번호
    let title: String // use in PlacesVC
    let thumbnailImage: String? // use in PlacesVC
    let distance: String // use in PlacesVC
    let latitude: Double // use in PlacesVC
    let longitude: Double // use in PlacesVC
    
    let detail: PlaceDetailModel?
    
    init(contentId: String, title: String, thumbnailImage: String?, distance: String, latitude: String?, longitude: String?, detail: PlaceDetailModel?) {
        self.contentId = contentId
        self.title = title
        self.thumbnailImage = thumbnailImage
        self.distance = distance
        self.latitude = Double(latitude ?? "0.0") ?? 0.0
        self.longitude = Double(longitude ?? "0.0") ?? 0.0
        self.detail = detail
    }
}

struct PlaceDetailModel {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let infoCenter: String? // 안내센터명 또는 전화번호
    let openTime: String? // 운영시간
}
