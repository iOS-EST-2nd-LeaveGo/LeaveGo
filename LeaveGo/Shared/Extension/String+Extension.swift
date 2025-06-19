//
//  String+Extension.swift
//  LeaveGo
//
//  Created by 박동언 on 6/18/25.
//

import Foundation

// MARK: - HTML 문자열을 일반 텍스트로 변환하는 String 확장
extension String {
    /// HTML 형식의 문자열을 NSAttributedString을 이용해 일반 문자열로 변환합니다.
    /// <p> 등의 태그가 포함된 응답 값을 정제할 때 사용
    var htmlToPlainText: String {
        guard let data = self.data(using: .utf8) else { return self }
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return attributedString.string
        }
        return self
    }
}
