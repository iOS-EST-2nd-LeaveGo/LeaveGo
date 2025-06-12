//
//  FetchPlaceList.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

extension NetworkManager {
    /// 한 번에 호출할 갯수를 지정하고 싶다면 numOfRows 로 전달하기 : 최대 100개 가능
    func fetchPlaceList(page: Int = 1, numOfRows: Int = 20, mapX: Double, mapY: Double, radius: Int) async throws -> [PlaceList]? {
        // 장소 목록을 담을 변수 선언
        var placeList = [PlaceList]()
        
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.placeList(page: page, numOfRows: numOfRows, mapX: mapX, mapY: mapY, radius: radius)
        
        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        
        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceList>.self) {
            placeList = data.response.body.items.item
            
            print("🙆‍♀️ API 호출 성공: \n\(placeList)")
            return placeList
        } else {
            return nil
        }
    }
}
