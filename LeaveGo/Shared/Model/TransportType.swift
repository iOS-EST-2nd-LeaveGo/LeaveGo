//
//  TransportType.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import Foundation

// 이동수단 Type
enum TransportType: String, CaseIterable {
    case walk = "도보"
    case transit = "대중교통"
    case car = "차량"

    var iconName: String {
        switch self {
        case .walk: return "figure.walk"
        case .transit: return "tram.fill"
        case .car: return "car"
        }
    }
}
