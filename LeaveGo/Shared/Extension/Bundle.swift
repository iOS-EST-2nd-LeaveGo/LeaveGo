//
//  Bundle.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/8/25.
//

import Foundation
import os

extension Bundle {
    
    var apiKey: String? {
        guard let file = self.path(forResource: "Secrets", ofType: "plist") else {
            os_log(.error, log: .default, "⛔️ Secrets.plist 파일을 찾을 수 없습니다.")
            return nil
        }
        
        guard let resource = NSDictionary(contentsOfFile: file),
              let key = resource["API_KEY"] as? String else {
            os_log(.error, log: .default, "⛔️ API KEY에 접근하지 못했습니다.")
            return nil
        }
        
        return key
    }
}
