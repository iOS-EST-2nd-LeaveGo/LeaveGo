//
//  FetchPlaceList.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

extension NetworkManager {
    /// 한 번에 호출할 갯수를 지정하고 싶다면 numOfRows 로 전달하기 : 최대 100개 가능
    func fetchPlaceList(page: Int = 1, numOfRows: Int = 100, mapX: Double, mapY: Double, radius: Int, contentTypeId: String?) async throws -> (places: [PlaceList], totalCount: Int) {
        // 장소 목록을 담을 변수 선언
        var placeList = [PlaceList]()
        var totalCount = 0

        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.placeList(page: page, numOfRows: numOfRows, mapX: mapX, mapY: mapY, radius: radius, contentTypeId: contentTypeId)

        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        print(newRequest)

        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceList>.self){
            placeList = data.response.body.items.item
            totalCount = data.response.body.totalCount
        }

        return (placeList, totalCount)
    }
}

