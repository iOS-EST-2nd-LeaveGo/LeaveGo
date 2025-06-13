//
//  FetchAreaBasedPlaceList.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import Foundation

extension NetworkManager {
    /// 한 번에 호출할 갯수를 지정하고 싶다면 numOfRows 로 전달하기 : 최대 100개 가능
    func FetchAreaBasedPlaceList(page: Int = 1, numOfRows: Int = 40, area: Area) async throws -> [AreaBasedPlaceList]? {
        // 장소 목록을 담을 변수 선언
        var placeList = [AreaBasedPlaceList]()
        
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.areaBasedPlaceList(page: page, numOfRows: numOfRows, area: area)
        
        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        
        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<AreaBasedPlaceList>.self) {
            placeList = data.response.body.items.item
            
            // print("🙆‍♀️ API 호출 성공: \n\(placeList)")
            return placeList
        } else {
            return nil
        }
    }
}
