//
//  FetchPlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

extension NetworkManager {
    func fetchPlaceDetail(contentId: Int, contentTypeId: Int) async throws -> PlaceDetail? {
        // 장소 목록을 담을 변수 선언
        var placeDetail: PlaceDetail?
        
        // endpoint 에 필수값들을 전달해 URL 생성
        let endpoint = Endpoint.placeDetail(contentId: contentId, contentTypeId: contentTypeId)
        
        // endpoint 에서 반환하는 url 을 가지고 request 생성
        let newRequest = try makeRequest(endpoint: endpoint)
        
        // let selectedContentTypeId = ContentTypeID(rawValue: contentTypeId)
        
        // request 와 디코딩 타입을 가지고 API 호출
        if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail>.self) {
            
            placeDetail = data.response.body.items.item.first
            print("🙆‍♀️ API 호출 성공: \n\(placeDetail)")
            return placeDetail
        }
        /*
        switch selectedContentTypeId {
        case .touristAttraction:
            if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail>.self) {
                placeDetail = data.response.body.items.item.first
                return placeDetail
            }
        case .cultureFacility:
            if let data = try await performRequest(urlRequest: newRequest, type: ResponseRoot<PlaceDetail>.self) {
                placeDetail = data.response.body.items.item.first
                return placeDetail
            }
            <#code#>
        case .leisureSports:
            <#code#>
        case .shopping:
            <#code#>
        case .restaurant:
            <#code#>
        case nil:
            <#code#>
        }
        */
        
        return nil
    }
}
