//
//  MypageSection.swift
//  LeaveGo
//
//  Created by 박동언 on 6/11/25.
//

import Foundation

enum MypageSection: Int, CaseIterable {
    case userSetting
    case userStorage

    var title: String {
        switch self {
        case .userSetting: return "사용자 설정"
        case .userStorage: return "저장소 관리"
        }
    }

    var items: [MypageItem] {
        switch self {
        case .userSetting:
            return [.changeNickname, .personalSetting]
        case .userStorage:
            return [.bookmarks, .offlinePlaces]
        }
    }
}
