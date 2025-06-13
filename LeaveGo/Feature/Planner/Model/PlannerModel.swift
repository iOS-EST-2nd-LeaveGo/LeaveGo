//
//  Planner.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import Foundation

class Planner {
    let title: String
    let thumnailPath: String?
    let placeList: [PlannerPlaceListModel]?
    
    init(title: String, thumnailPath: String?, placeList: [PlannerPlaceListModel]?) {
        self.title = title
        self.thumnailPath = thumnailPath
        self.placeList = placeList
    }
}

// 더미 데이터
let mockPlanners = [
    Planner(title: "👒 모두 다함께 광화문 여행을 떠나봅시다", thumnailPath: nil, placeList: nil),
    Planner(title: "🌊 부산 여행", thumnailPath: nil, placeList: nil),
    Planner(title: "🚀 우주 여행 ✨", thumnailPath: nil, placeList: nil)
]
