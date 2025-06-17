//
//  PlaceListRaw.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/8/25.
//

import Foundation

struct PlaceList: Codable {
    let addr1: String? // 주소
    let addr2: String? // 상세주소
    let areaCode: String? // 지역코드
    let cat1: String? // 대분류코드
    let cat2: String? // 중분류코드
    let cat3: String? // 소분류코드
    let contentId: String // 장소 고유번호
    let contentTypeId: String // 장소 관광지 타입
    let dist: String? // 중심 좌표로부터의 거리
    let thumbnailImage: String? // 썸네일이미지
    // API 응답값이 (1) 정상적인 url, (2) null, (3) 빈 문자열("") 로 들어오기 때문에 URL? 이 아닌 String? 으로 지정
    let mapX: String? // 경도
    let mapY: String? // 위도
    let tel: String? // 전화번호
    let title: String // 장소명
    
    enum CodingKeys: String, CodingKey {
        case addr1
        case addr2
        case areaCode = "areacode"
        case cat1
        case cat2
        case cat3
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case dist
        case thumbnailImage = "firstimage2" // 썸네일용 이미지는 firstimage2 에 담겨오는데 이름이 직관적이지 않아서 변경
        case mapX = "mapx"
        case mapY = "mapy"
        case tel
        case title
    }
}
