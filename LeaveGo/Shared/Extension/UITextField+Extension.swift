//
//  UITextField+Extension.swift
//  LeaveGo
//
//  Created by 박동언 on 6/10/25.
//

import UIKit

extension UITextField {
    // Placeholder 왼쪽 여백
//    func setLeftPadding(_ padding: CGFloat) {
//        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
//        self.leftViewMode = .always
//
//    }

    // shouldChangeCharactersIn 이전 문자열, 입력 문자 결합
    static func replacingText(text: String, range: NSRange, string: String) -> String? {
        guard let range = Range(range, in: text) else { return nil }

        let finalText = text.replacingCharacters(in: range, with: string)

        return finalText
    }
}
