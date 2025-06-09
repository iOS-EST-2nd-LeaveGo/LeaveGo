//
//  PlaceListModel.swift
//  LeaveGo
//
//  Created by YC on 6/9/25.
//

import Foundation

// 최상위 응답 구조
struct APIResponse: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct Header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct Body: Codable {
    let items: Items
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct Items: Codable {
    let item: [Place]
}

// 실제 데이터 모델
struct Place: Codable {
    let contentid: String
    let title: String
    let addr1: String
    let dist: String
    let firstimage: String?
}
