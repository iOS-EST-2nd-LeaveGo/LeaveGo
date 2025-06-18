//
//  UIImageView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/18/25.
//

import Foundation
import UIKit

extension UIImageView {
    func addGradientOverlay(to imageView: UIImageView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        
        // 색상 정의 (검정색, 투명 → 불투명)
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor
        ]
        
        // 위치 정의 (0% → 100%)
        gradientLayer.locations = [0.0, 1.0]
        
        // 방향 (위에서 아래)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        imageView.layer.addSublayer(gradientLayer)
    }
}
