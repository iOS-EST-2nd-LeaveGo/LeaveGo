//
//  MypageItem.swift
//  LeaveGo
//
//  Created by 박동언 on 6/10/25.
//

import Foundation

enum MypageItem: String, CaseIterable {
    case editNickname
    case personalSetting
    case bookmarks

    var title: String {
        switch self {
        case .editNickname: return "닉네임 변경"
        case .personalSetting: return "개인 설정 변경"
        case .bookmarks: return "북마크 장소"
        }
    }

    var iconName: String {
        switch self {
        case .editNickname: return "figure.walk"
        case .personalSetting: return "bicycle"
        case .bookmarks: return "car"
        }
    }
}
