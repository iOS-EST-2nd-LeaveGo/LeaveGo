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
    
    init(title: String, thumnailPath: String?) {
        self.title = title
        self.thumnailPath = thumnailPath
    }
}

// 더미 데이터
let mockPlanners = [
    Planner(title: "👒 모두 다함께 광화문 여행을 떠나봅시다", thumnailPath: nil),
    Planner(title: "🌊 부산 여행", thumnailPath: nil),
    Planner(title: "🚀 우주 여행 ✨", thumnailPath: nil)
]
