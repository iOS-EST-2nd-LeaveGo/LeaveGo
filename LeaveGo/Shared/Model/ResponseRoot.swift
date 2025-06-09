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
}
