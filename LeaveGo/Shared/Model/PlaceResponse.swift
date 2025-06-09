//
//  PlaceResponse.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/8/25.
//

import Foundation

struct PlaceResponse: Codable {
    let header: ResponseHeader
    let body: ResponseBody
    
    struct ResponseHeader: Codable {
        let resultCode: String
        let resultMsg: String
    }
    
    struct ResponseBody: Codable {
        let items: Item
        let numOfRows: Int
        let pageNo: Int
        let totalCount: Int
        
        struct Item: Codable {
            let place: Place
            
            struct Place: Codable {
                let addr1: String
                let addr2: String
                let areacode: String
                let cat1: String
                let cat2: String
                let cat3: String
                let contentid: String
                let contenttypeid: String
                let dist: String
                let firstimage: String
                let mapx: String
                let mapy: String
                let tel: String
                let title: String
            }
        }
    }
}
