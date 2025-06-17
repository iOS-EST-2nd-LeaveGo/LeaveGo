//
//  PlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

protocol PlaceDetailProtocol {
    var contentId: String { get }
    var contentTypeId: String { get }
    var parking: String? { get }
    var infoCenter: String? { get }
    var openDate: String? { get }
    var openTime: String? { get }
    var restDate: String? { get }
}
