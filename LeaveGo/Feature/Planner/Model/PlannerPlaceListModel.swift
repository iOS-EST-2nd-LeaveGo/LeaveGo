//
//  PlannerPlaceListModel.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/14/25.
//

import Foundation

class PlannerPlaceListModel {
    let area: Area
    let places: [PlannerPlace?]
    
    class PlannerPlace {
        let title: String
        let contentId: Int
        let contentTypeId: Int?
        
        init(title: String, contentId: Int, contentTypeId: Int?) {
            self.title = title
            self.contentId = contentId
            self.contentTypeId = contentTypeId
        }
    }
    
    init(area: Area, places: [PlannerPlace?]) {
        self.area = area
        self.places = places
    }
}
