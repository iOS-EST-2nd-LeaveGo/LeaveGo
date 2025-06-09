//
//  PlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

struct PlaceDetail: Codable {
    let contentid: String // 관광지 고유번호
    let contenttypeid: String // 관광지 타입
    let kidsfacility: String? // 놀이방 여부
    let parking: String? // 주차 가능여부
    let infocenterfood: String? // 전화번호
    let opendatefood: String? // 운영요일
    let opentimefood: String? // 운영시간
    let restdatefood: String? // 연중무휴 여부
}
