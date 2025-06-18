//
//  FetchPlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

extension NetworkManager {
    func fetchPlaceDetail(contentTypeId: String, contentId: String) async throws -> PlaceDetailProtocol? {
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.placeDetail(contentTypeId: contentTypeId, contentId: contentId)

        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        
        // request 와 디코딩 타입을 가지고 API 호출
        switch contentTypeId {
         case "12":
             if let result = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail12>.self) {
                 return result.response.body.items.item.first?.htmlCleaned()
             }
         case "14":
             if let result = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail14>.self) {
                 return result.response.body.items.item.first?.htmlCleaned()
             }
         case "28":
             if let result = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail28>.self) {
                 return result.response.body.items.item.first?.htmlCleaned()
             }
         case "38":
             if let result = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail38>.self) {
                 return result.response.body.items.item.first?.htmlCleaned()
             }
        case "39":
            if let result = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail39>.self) {
                return result.response.body.items.item.first?.htmlCleaned()
            }
         default:
             print("처리되지 않은 contentTypeId: \(contentTypeId)")
             return nil
         }

        return nil
    }
}
