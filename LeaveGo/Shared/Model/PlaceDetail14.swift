//
//  PlaceDetail14.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

/// 문화시설
struct PlaceDetail14: Codable, PlaceDetailProtocol {
    var openDate: String?
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let parking: String? // 주차 가능여부
    let infoCenter: String? //
    let openTime: String? // 운영시간
    let restDate: String? // 연중무휴 여부
    let duration: String? // 관람 소요시간
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking = "parkingculture"
        case infoCenter = "infocenterculture"
        case openTime = "usetimeculture"
        case restDate = "restdateculture"
        case duration = "spendtime"
    }
}
