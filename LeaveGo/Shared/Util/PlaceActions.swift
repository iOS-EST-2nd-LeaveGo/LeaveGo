//
//  PlaceActions.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import Foundation
import SwiftUI

enum PlaceActions {
    static func presentInfoModal(from view: UIView) {
        guard let vc = view.parentViewController() else {
            print("❌ 부모 VC 를 찾을 수 없음")
            return
        }

        let storyboard = UIStoryboard(name: String(describing: Planner.self), bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: String(describing: PlaceDetailModalViewController.self)) as! PlaceDetailModalViewController
        vc.present(modalVC, animated: true)
        modalVC.sheetPresentationController?.detents = [.medium()]
    }
}
