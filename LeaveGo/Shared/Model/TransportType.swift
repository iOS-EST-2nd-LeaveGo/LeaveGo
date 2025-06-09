//
//  TransportType.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import Foundation

enum TransportType: String, CaseIterable {
    case walk = "도보"
    case bicycle = "자전거"
    case car = "차량"

    var iconName: String {
        switch self {
        case .walk: return "bicycle"
        case .bicycle: return "figure.walk"
        case .car: return "car"
        }
    }
}
