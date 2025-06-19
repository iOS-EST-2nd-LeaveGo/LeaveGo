//
//  Endpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

/// Endpoint 별로 파라메터를 포함한 최종 URL 을 반환해주는 Enum
enum Endpoint {
    case placeList(page: Int, numOfRows: Int, mapX: Double, mapY: Double, radius: Int, contentTypeId: Int?, arrange: String)
    case placeDetail(contentTypeId: String, contentId: String)
    case areaBasedPlaceList(page: Int, numOfRows: Int, area: Area)
    case keywordPlaceList(page: Int, numOfRows: Int, keyword: String)

    var url: URL? {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return nil }
        
        switch self {
        case let .placeList(page, numOfRows, mapX, mapY, radius, contentTypeId, arrange):
            let strContentTypeId = contentTypeId.map { "\($0)" } ?? ""
            let urlString = """
            https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=\(strContentTypeId)&numOfRows=\(numOfRows)&pageNo=\(page)&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&arrange=\(arrange)&serviceKey=\(apikey)
            """
            return URL(string: urlString)
        case let .placeDetail(contentTypeId, contentId):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/detailIntro2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=\(contentTypeId)&contentId=\(contentId)&serviceKey=\(apikey)")
        case let .areaBasedPlaceList(page, numOfRows, area):
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/areaBasedSyncList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&contentTypeId=12&numOfRows=\(numOfRows)&pageNo=\(page)&areaCode=\(area.code)&serviceKey=\(apikey)")
        case let .keywordPlaceList(page, numOfRows, keyword):
            let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "https://apis.data.go.kr/B551011/KorService2/searchKeyword2?MobileOS=IOS&MobileApp=LeaveGo&_type=json&numOfRows=\(numOfRows)&pageNo=\(page)&keyword=\(encodedKeyword)&serviceKey=\(apikey)")
        }
    }
}
