//
//  FetchKeywordPlaceList.swift
//  LeaveGo
//
//  Created by 박동언 on 6/16/25.
//

import Foundation

extension NetworkManager {

    func fetchKeywordPlaceList(page: Int = 1, numOfRows: Int = 100, keyword: String) async throws -> (places: [PlaceList], totalCount: Int) {
        // 장소 목록을 담을 변수 선언
        var placeList = [PlaceList]()
		var totalCount = 0
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.keywordPlaceList(page: page, numOfRows: numOfRows, keyword: keyword)

        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)

        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceList>.self) {
            placeList = data.response.body.items.item
            totalCount = data.response.body.totalCount
        }

        return (placeList, totalCount)
    }
}
