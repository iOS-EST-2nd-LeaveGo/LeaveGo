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
    let distance: String? // 거리(use in PlacesVC)
    let latitude: Double // (use in PlacesVC)
    let longitude: Double // (use in PlacesVC)
    let areaCode: String? // 지역코드
    let cat1: String? // 대분류코드
    let cat2: String? // 중분류코드
    let cat3: String? // 소분류코드
    
    // let detail: PlaceDetailModel?
    
    init(contentId: String, title: String, thumbnailURL: String?, distance: String, latitude: String?, longitude: String?/*, detail: PlaceDetailModel?*/, areaCode: String?, cat1: String?, cat2: String?, cat3: String?) {
        self.contentId = contentId
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.distance = distance
        self.latitude = Double(latitude ?? "") ?? 0.0
        self.longitude = Double(longitude ?? "") ?? 0.0
        // self.detail = detail
        self.areaCode = areaCode
        self.cat1 = cat1
        self.cat2 = cat2
        self.cat3 = cat3
    }
    
}

extension PlaceModel {
    
    /// MapViewContoller에서 mapview에 전달 하기위해 annotaionModel형태로 전달해야 합니다.
    func toAnnotationModel() -> PlaceAnnotationModel {
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                             title: title,
                             thumbnailImage: thumbnailImage,
                             areaCode: areaCode,
                             cat1: cat1,
                             cat2: cat2,
                             cat3: cat3)
    }
    
}

extension PlaceModel {
    init(from bookmark: BookmarkEntity) {
        self.contentId = bookmark.contentID ?? ""
        self.title = bookmark.source ?? "제목 없음"
        self.thumbnailURL = nil // URL은 없으므로 nil
        self.thumbnailImage = {
            if let data = bookmark.thumbnailImage {
                return UIImage(data: data)
            } else {
                return nil
            }
        }()
        self.distance = nil // 북마크는 거리와 무관하므로 nil
        self.latitude = 0.0
        self.longitude = 0.0
        self.areaCode = nil
        self.cat1 = nil
        self.cat2 = nil
        self.cat3 = nil
    }
}

struct PlaceDetailModel {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let infoCenter: String? // 안내센터명 또는 전화번호
    let openTime: String? // 운영시간
}
