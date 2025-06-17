//
//  PlaceModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/12/25.
//

import CoreLocation
import UIKit

struct PlaceModel {
    let add1: String?
    let add2: String?
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
    
    init(add1: String?, add2: String?, contentId: String, title: String, thumbnailURL: String?, distance: String?, latitude: String?, longitude: String?/*, detail: PlaceDetailModel?*/, areaCode: String?, cat1: String?, cat2: String?, cat3: String?) {
        self.add1 = add1
        self.add2 = add2
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
    init(from place: PlaceList) {
        self.add1 = place.addr1
        self.add2 = place.addr2
        self.contentId = place.contentId
        self.title = place.title
        self.thumbnailURL = place.thumbnailImage
        self.thumbnailImage = nil
        self.distance = place.dist
        self.latitude = Double(place.mapY ?? "") ?? 0.0
        self.longitude = Double(place.mapX ?? "") ?? 0.0
        self.areaCode = place.areaCode
        self.cat1 = place.cat1
        self.cat2 = place.cat2
        self.cat3 = place.cat3
    }

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
        self.title = bookmark.title ?? "제목 없음"
        self.thumbnailURL = bookmark.thumbnailImageURL // URL은 없으므로 nil
        self.thumbnailImage = nil
        self.distance = nil // 북마크는 거리와 무관하므로 nil
        self.latitude = 0.0
        self.longitude = 0.0
        self.areaCode = nil
        self.cat1 = nil
        self.cat2 = nil
        self.cat3 = nil
        self.add1 = ""
        self.add2 = ""
    }

    func toBookmarkEntity() -> BookmarkEntity {
        let context = CoreDataManager.shared.context
        let entity = BookmarkEntity(context: context)
        
        entity.createdAt = Date()
        entity.contentID = self.contentId
        entity.title = self.title
        entity.thumbnailImageURL = thumbnailURL
        
        return entity
    }
}

struct PlaceDetailModel {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let infoCenter: String? // 안내센터명 또는 전화번호
    let openTime: String? // 운영시간
}
