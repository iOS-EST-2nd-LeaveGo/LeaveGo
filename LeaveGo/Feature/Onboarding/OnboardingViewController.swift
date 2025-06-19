//
//  OnboardingViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

// MARK: - 앱 최초 실행 시 사용자에게 앱 소개를 보여주는 온보딩 화면
class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let totalPages = stackView.arrangedSubviews.count
        pageControl.numberOfPages = totalPages
        pageControl.currentPage = 0
        
        // 2) 페이징 활성화 & 델리게이트 연결
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        // 3) 버튼 초기 스타일
        saveButton.isEnabled = false
        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true
        
        navigationItem.backButtonTitle = ""
    }
}

// MARK: - 스크롤 이동에 따라 페이지 컨트롤 및 버튼 상태 갱신
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
        
        saveButton.isEnabled = (page == pageControl.numberOfPages - 1)
    }
}


