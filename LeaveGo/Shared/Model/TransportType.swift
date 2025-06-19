//
//  TransportType.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import Foundation
import MapKit
// 이동수단 Type
enum TransportType: String, CaseIterable {
    case walking = "도보"
    case transit = "대중교통"
    case automobile = "차량"

    var iconName: String {
        switch self {
        case .walking: return "figure.walk"
        case .transit: return "tram.fill"
        case .automobile: return "car"
        }
    }

    var mapKitType: MKDirectionsTransportType {
        switch self {
        case .automobile: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        }
    }
}
