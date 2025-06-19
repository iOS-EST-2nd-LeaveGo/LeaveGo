//
//  PlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

// MARK: - 장소 상세 정보 공통 인터페이스 정의
/// 관광지, 음식점, 쇼핑 등 다양한 유형의 장소 상세 데이터를 공통 처리하기 위한 프로토콜
protocol PlaceDetailProtocol {
    var contentId: String { get }
    var contentTypeId: String { get }
    var parking: String? { get }
    var infoCenter: String? { get }
    var openDate: String? { get }
    var openTime: String? { get }
    var restDate: String? { get }

    /// HTML 태그 제거 또는 정제 처리된 데이터를 반환
    func htmlCleaned() -> Self
}
