//
//  PlaceDetail28.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

/// 레포츠
struct PlaceDetail28: Codable, PlaceDetailProtocol {
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let parking: String? // 주차 가능여부
    var infoCenter: String? // 안내센터명 또는 전화번호
    let openDate: String? // 운영요일
    var openTime: String? // 운영시간
    var restDate: String? // 연중무휴 여부

    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking = "parkingleports"
        case infoCenter = "infocenterleports"
        case openDate = "openperiod"
        case openTime = "usetimeleports"
        case restDate = "restdateleports"
    }

    func htmlCleaned() -> PlaceDetail28 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}
