//
//  ResponseRoot.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

struct ResponseRoot<T: Codable>: Codable {
    let response: APIResponse<T>
}

struct APIResponse<T: Codable>: Codable {
    let header: ResponseHeader
    let body: ResponseBody<T>
}

struct ResponseHeader: Codable {
    let resultCode: String
    let resultMsg: String
}

struct ResponseBody<T: Codable>: Codable {
    let items: Item<T>
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct Item<T: Codable>: Codable {
    let item: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // items가 "" 빈 문자열이면 빈 배열로 초기화
        if let _ = try? container.decode(String.self) {
            self.item = []
        } else {
            // 정상적으로 디코딩 가능한 경우
            let object = try container.decode([String: [T]].self)
            self.item = object["item"] ?? []
        }
    }

    init(item: [T]) {
        self.item = item
    }
}
