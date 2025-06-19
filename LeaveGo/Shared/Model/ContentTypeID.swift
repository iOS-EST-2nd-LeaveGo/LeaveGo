//
//  ContentTypeID.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/11/25.
//

import Foundation

enum ContentTypeID: Int, CaseIterable {
    case touristAttraction = 12
    case cultureFacility = 14
    // case festival = 15
    // case travelCourse = 25
    case leisureSports = 28
    // case accommodation = 32
//    case shopping = 38
    case restaurant = 39

    static func from(_ int: Int) -> ContentTypeID? {
        return ContentTypeID(rawValue: int)
    }
}

