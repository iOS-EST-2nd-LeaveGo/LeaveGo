//
//  Validation.swift
//  LeaveGo
//
//  Created by 박동언 on 6/10/25.
//

import Foundation

struct Validation {
    // 외부에서 인스턴스 생성 금지
    private init() { }

    // 닉네임 검증
    // 공백 x, 알파벳/한글/숫자만 허용, 2~6글자 허용
    static func isValidNickname(_ nickname: String) -> Bool {
        let validNickname = nickname.filter { !$0.isWhitespace }

        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn:
        	"가힣"))

        guard validNickname.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil else {
            return false
        }

        guard (2...6).contains(validNickname.count) else {
            return false
        }

        return true
    }
}
