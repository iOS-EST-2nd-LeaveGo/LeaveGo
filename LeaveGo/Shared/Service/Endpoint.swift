//
//  Endpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

enum Endpoint {
    case placeList(mapX: Double, mapY: Double, radius: Int)
    case placeDetail(contentId: Int, contentTypeId: Int)
    
    var url: URL? {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return nil }
        
        switch self {
        case let .placeList(mapX, mapY, radius):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&serviceKey=\(apikey)")
        case let .placeDetail(contentId, contentTypeId):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/detailIntro2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentId=\(contentId)&contentTypeId=\(contentTypeId)&serviceKey=\(apikey)")
        }
    }
}
