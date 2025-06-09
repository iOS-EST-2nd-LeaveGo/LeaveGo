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
    case bus = "버스"
    case subway = "지하철"
    case motorcycle = "오토바이"
    case scooter = "킥보드"
    case train = "기차"
    case airplane = "비행기"
    case ferry = "배"
    case campingCar = "캠핑카"
    case tram = "트램"
    case taxi = "택시"

    var iconName: String {
        switch self {
        case .walk: return "figure.walk"
        case .bicycle: return "bicycle"
        case .car: return "car"
        case .bus: return "bus"
        case .subway: return "tram.fill" // 대체로 지하철용
        case .motorcycle: return "scooter" // 적당한 대체 아이콘
        case .scooter: return "scooter"
        case .train: return "train.side.front.car"
        case .airplane: return "airplane"
        case .ferry: return "ferry"
        case .campingCar: return "caravan"
        case .tram: return "cablecar"
        case .taxi: return "car.fill.taxi"
        }
    }
}
