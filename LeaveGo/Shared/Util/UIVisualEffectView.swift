//
//  UIVisualEffectView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/17/25.
//

import Foundation
import UIKit

extension UIVisualEffectView {
    func applyFeatherMask(to view: UIView, featherHeight: CGFloat = 50.0) {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = view.bounds

        maskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        maskLayer.locations = [
            0.0,
            NSNumber(value: Float(featherHeight / view.bounds.height))
        ]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.mask = maskLayer
    }
}
