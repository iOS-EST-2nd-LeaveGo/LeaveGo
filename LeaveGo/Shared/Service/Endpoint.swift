//
//  Endpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

/// Endpoint 별로 파라메터를 포함한 최종 URL 을 반환해주는 Enum
enum Endpoint {
    case placeList(page: Int, numOfRows: Int, mapX: Double, mapY: Double, radius: Int)
    case placeDetail(contentId: Int)
    case areaBasedPlaceList(page: Int, numOfRows: Int, area: Area)
    
    var url: URL? {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return nil }
        
        switch self {
        case let .placeList(page, numOfRows, mapX, mapY, radius):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=12&numOfRows=\(numOfRows)&pageNo=\(page)&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&serviceKey=\(apikey)")
        case let .placeDetail(contentId):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/detailIntro2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=12&contentId=\(contentId)&serviceKey=\(apikey)")
        case let .areaBasedPlaceList(page, numOfRows, area):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/areaBasedSyncList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=12&numOfRows=\(numOfRows)&pageNo=\(page)&areaCode=\(area.code)&serviceKey=\(apikey)")
        }
    }
}
