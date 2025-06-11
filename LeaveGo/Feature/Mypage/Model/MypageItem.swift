//
//  MypageItem.swift
//  LeaveGo
//
//  Created by 박동언 on 6/10/25.
//

import Foundation

enum MypageItem: String, CaseIterable {
    case changeNickname
    case personalSetting
    case bookmarks
    case offlinePlaces

    var title: String {
        switch self {
        case .changeNickname: return "닉네임 변경"
        case .personalSetting: return "개인 설정 변경"
        case .bookmarks: return "북마크 장소"
        case .offlinePlaces: return "오프라인 저장 장소"
        }
    }
}
