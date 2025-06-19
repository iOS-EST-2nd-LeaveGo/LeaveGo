//
//  Area.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import Foundation

enum Area: CaseIterable {
    case seoul
    case incheon
    case daejeon
    case daegu
    case gwangju
    case busan
    case ulsan
    case sejong
    case gyeonggi
    case gangwon
    case chungcheongNorth
    case chungcheongSouth
    case gyeongsangNorth
    case gyeongsangSouth
    case jeollaNorth
    case jeollaSouth
    case jeju
    
    var code: Int {
        switch self {
        case .seoul: return 1
        case .incheon: return 2
        case .daejeon: return 3
        case .daegu: return 4
        case .gwangju: return 5
        case .busan: return 6
        case .ulsan: return 7
        case .sejong: return 8
        case .gyeonggi: return 31
        case .gangwon: return 32
        case .chungcheongNorth: return 33
        case .chungcheongSouth: return 34
        case .gyeongsangNorth: return 35
        case .gyeongsangSouth: return 36
        case .jeollaNorth: return 37
        case .jeollaSouth: return 38
        case .jeju: return 39
        }
    }
    
    var name: String {
        switch self {
        case .seoul: return "서울"
        case .incheon: return "인천"
        case .daejeon: return "대전"
        case .daegu: return "대구"
        case .gwangju: return "광주"
        case .busan: return "부산"
        case .ulsan: return "울산"
        case .sejong: return "세종"
        case .gyeonggi: return "경기도"
        case .gangwon: return "강원도"
        case .chungcheongNorth: return "충청북도"
        case .chungcheongSouth: return "충청남도"
        case .gyeongsangNorth: return "경상북도"
        case .gyeongsangSouth: return "경상남도"
        case .jeollaNorth: return "전라북도"
        case .jeollaSouth: return "전라남도"
        case .jeju: return "제주"
        }
    }
    
    var fullName: String {
        switch self {
        case .seoul: return "서울특별시"
        case .incheon: return "인천광역시"
        case .daejeon: return "대전광역시"
        case .daegu: return "대구광역시"
        case .gwangju: return "광주광역시"
        case .busan: return "부산광역시"
        case .ulsan: return "울산광역시"
        case .sejong: return "세종특별자치시"
        case .gyeonggi: return "경기도"
        case .gangwon: return "강원도"
        case .chungcheongNorth: return "충청북도"
        case .chungcheongSouth: return "충청남도"
        case .gyeongsangNorth: return "경상북도"
        case .gyeongsangSouth: return "경상남도"
        case .jeollaNorth: return "전라북도"
        case .jeollaSouth: return "전라남도"
        case .jeju: return "제주시"
        }
    }
}

