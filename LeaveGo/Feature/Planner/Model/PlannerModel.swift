//
//  Planner.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import Foundation

class Planner {
    let title: String
    let thumbnailPath: String?
    let placeList: [PlannerPlaceListModel]?
    
    init(title: String, thumnailPath: String?, placeList: [PlannerPlaceListModel]?) {
        self.title = title
        self.thumbnailPath = thumnailPath
        self.placeList = placeList
    }
}

// 더미 데이터
let mockPlanners = [
    Planner(title: "👒 모두 다함께 광화문 여행을 떠나봅시다", thumnailPath: nil, placeList: nil),
    Planner(title: "🌊 부산 여행", thumnailPath: nil, placeList: nil),
    Planner(title: "🚀 우주 여행 ✨", thumnailPath: nil, placeList: nil)
]

extension Planner {
    convenience init?(entity: PlannerEntity) {
        guard let title = entity.title else { return nil }
        
        // 관계형 데이터(placeList)는 일단 nil 처리하거나 나중에 매핑 추가
        let placeModels: [PlannerPlaceListModel]? = nil

        self.init(title: title, thumnailPath: entity.thumbnailPath, placeList: placeModels)
    }
}
