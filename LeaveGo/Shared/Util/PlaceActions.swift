//
//  PlaceActions.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import Foundation
import SwiftUI

enum PlaceActions {
    // Cell 에서 모달을 생성하기 위해 부모 뷰를 찾기
    static func presentInfoModal(from view: UIView, mode: DetailMode, placeId: Int, placeTitle: String, dist: String?) {
        guard let vc = view.parentViewController() else {
            print("❌ 부모 VC 를 찾을 수 없음")
            return
        }

        let storyboard = UIStoryboard(name: String(describing: Planner.self), bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: String(describing: PlaceDetailModalViewController.self)) as! PlaceDetailModalViewController
        modalVC.placeId = placeId
        modalVC.placeTitle = placeTitle
        modalVC.sheetPresentationController?.detents = [.medium()]
        
        vc.present(modalVC, animated: true)
    }
}
