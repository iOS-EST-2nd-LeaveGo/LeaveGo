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

let mockPlanner = Planner(title: "여름 휴가 계획", thumnailPath: nil)
