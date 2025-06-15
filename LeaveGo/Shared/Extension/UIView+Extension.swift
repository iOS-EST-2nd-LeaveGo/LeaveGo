//
//  UIView+Extension.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import Foundation
import SwiftUI

extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
