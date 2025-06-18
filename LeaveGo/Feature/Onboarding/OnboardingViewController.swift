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

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
		pageControl.currentPage = page

		saveButton.isEnabled = (page == pageControl.numberOfPages - 1)
    }
}


