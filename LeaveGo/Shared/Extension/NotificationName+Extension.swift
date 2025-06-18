//
//  NotificationName+Extension.swift
//  LeaveGo
//
//  Created by 박동언 on 6/11/25.
//

import Foundation

extension Notification.Name {
    // 닉네임 이동수단 온보딩 뷰와 닉네임, 이동수단 변경 뷰 분기 시 활용
    static let nicknameDidChange = Notification.Name("nicknameDidChange")
    static let transportDidChange = Notification.Name("transportDidChange")

    // 장소 모댈 업데이트 시
    static let placeModelUpdated = Notification.Name("placeModelUpdated")
    static let mapDidMove = Notification.Name("mapDidMove")
    
    // 사용자 위치 업데이트 시
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
    static let headingDidUpdate = Notification.Name("headingDidUpdate")
    static let locationUpdateDidFail = Notification.Name("locationUpdateDidFail")
    
    static let didCreateNewPlanner = Notification.Name("didCreateNewPlanner")
}
