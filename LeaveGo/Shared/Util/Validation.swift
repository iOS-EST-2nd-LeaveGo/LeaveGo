//
//  Validation.swift
//  LeaveGo
//
//  Created by 박동언 on 6/10/25.
//

import Foundation

enum Validation {
    // 닉네임 검증
    // 공백 x, 알파벳/한글/숫자만 허용, 2~6글자 허용
    static func isValidNickname(_ nickname: String) -> Bool {
        let trimmedNickname = nickname.filter { !$0.isWhitespace }

        do {
            let regex = try Regex("^[가-힣A-Za-z0-9]{2,6}$")
            return trimmedNickname.wholeMatch(of: regex) != nil
        } catch {
            print(error)
            return false
        }
    }
}
