//
//  FetchPlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

// MARK: - 장소 상세 정보 요청 확장 (contentTypeId 에 따라 모델 분기 처리)
extension NetworkManager {
    /// contentTypeId 에 따라 적절한 타입으로 디코딩하여 장소 상세 정보를 요청합니다.
    /// - Parameters:
    ///   - contentTypeId: 장소 유형 ID (예: 관광지 12, 문화시설 14 등)
    ///   - contentId: 장소 고유 ID
    /// - Returns: PlaceDetailProtocol 을 따르는 디코딩된 객체
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
