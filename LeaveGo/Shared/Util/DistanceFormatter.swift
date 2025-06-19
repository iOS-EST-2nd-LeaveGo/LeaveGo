//
//  DistanceFormatter.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/18/25.
//

import Foundation

extension String {
    func formattedDistance() -> String {
        guard let value = Double(self) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: Int(round(value)))) ?? ""
    }
}
