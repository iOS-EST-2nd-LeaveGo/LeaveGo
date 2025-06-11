//
//  UserSetting.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import Foundation

// UserDefaults Setting
// 닉네임, 여행취향, 선호이동수단
final class UserSetting {
    static let shared = UserSetting()

    private init() { }

    enum Key {
        static let nickname = "nickname"
        static let userTripPreferences = "userTripPreferences"
        static let preferredTransport = "preferredTransport"
    }

    var nickname: String? {
        get {
            UserDefaults.standard.string(forKey: Key.nickname)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.nickname)
        }
    }

    var userTripPreferences: [UserTripPreference] {
        get {
            guard let rawValues = UserDefaults.standard.array(forKey: Key.userTripPreferences) as? [String] else { return [] }
            return rawValues.compactMap { UserTripPreference(rawValue: $0 ) }
        }
        set {
            let rawValues = newValue.map { $0.rawValue }
            UserDefaults.standard.set(rawValues, forKey: Key.userTripPreferences)
        }
    }

    var preferredTransport: TransportType? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Key.preferredTransport) else { return nil }
            return TransportType(rawValue: rawValue)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Key.preferredTransport)
        }
    }
}
