//
//  String+Extension.swift
//  LeaveGo
//
//  Created by 박동언 on 6/18/25.
//

import Foundation

extension String {
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
