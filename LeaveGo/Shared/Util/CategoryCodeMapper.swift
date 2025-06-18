//
//  CategoryCodeMapper.swift
//  LeaveGo
//
//  Created by 박동언 on 6/19/25.
//

import Foundation

struct CategoryCodeMapper {

    private static let codeToNameMap: [String: String] = [
        "A01": "자연",
        "A02": "인문(문화/예술/역사)",
        "A03": "레포츠",
        "A04": "쇼핑",
        "A05": "음식",
        "B02": "숙박",
        "C01": "추천코스"
    ]

    static func name(for code: String) -> String {
        return codeToNameMap[code] ?? "기타"
    }
}
