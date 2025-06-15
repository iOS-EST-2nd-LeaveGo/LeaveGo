//
//  PlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

/// 관광지 타입 12
struct PlaceDetail: Codable {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let parking: String? // 주차 가능여부
    let infoCenter: String? // 안내센터명 또는 전화번호
    let openDate: String? // 운영요일
    let openTime: String? // 운영시간
    let restDate: String? // 연중무휴 여부
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking
        case infoCenter = "infocenter"
        case openDate = "opendate"
        case openTime = "usetime"
        case restDate = "restdate"
    }
}
