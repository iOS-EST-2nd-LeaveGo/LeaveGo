//
//  OnboardingViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

// 온보딩 소개화면 추후구현
class OnboardingViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false

        navigationItem.backButtonTitle = ""

        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)

        if pageControl.currentPage == 2 {
            saveButton.isEnabled = true
        }
    }
}
