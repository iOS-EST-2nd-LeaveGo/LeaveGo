//
//  PlaceActions.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import Foundation
import UIKit

enum PlaceActions {
    // Cell 에서 모달을 생성하기 위해 부모 뷰를 찾기
    static func presentInfoModal(from view: UIView, place: PlaceModel) {
        guard let vc = view.parentViewController() else {
            print("❌ 부모 VC 를 찾을 수 없음")
            return
        }

        let storyboard = UIStoryboard(name: String(describing: Planner.self), bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: String(describing: PlaceDetailModalViewController.self)) as! PlaceDetailModalViewController
        modalVC.place = place
        modalVC.sheetPresentationController?.detents = [
            .custom { context in 320 },
            .medium()
        ]
        modalVC.sheetPresentationController?.prefersGrabberVisible = true
        
        vc.present(modalVC, animated: true)
    }
}
