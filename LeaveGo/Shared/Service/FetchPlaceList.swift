//
//  FetchPlaceList.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

extension NetworkManager {
    func fetchPlaceList(page: Int = 1, mapX: Double, mapY: Double, radius: Int) async throws -> [PlaceList]? {
        // 장소 목록을 담을 변수 선언
        var placeList = [PlaceList]()
        
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.placeList(page: page, mapX: mapX, mapY: mapY, radius: radius)
        
        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        
        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceList>.self) {
            if data.response.body.totalCount > 1 {
                // 변수에 장소 목록 업데이트
                placeList = data.response.body.items.item
            } else {
                return placeList
            }
            print("🙆‍♀️ API 호출 성공: \n\(placeList)")
            return placeList
        } else {
            return nil
        }
    }
}
