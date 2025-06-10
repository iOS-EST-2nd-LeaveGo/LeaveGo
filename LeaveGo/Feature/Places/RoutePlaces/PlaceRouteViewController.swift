//
//  PlaceRouteViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class PlaceRouteViewController: UIViewController {
	@IBOutlet weak var locationContainer: UIView!
	private var bottomSheet: RouteBottomSheetViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		embedBottomSheet()
	}
	
	private func setupUI() {
		locationContainer.layer.cornerRadius = 10
		locationContainer.clipsToBounds = true
	}
	
	private func embedBottomSheet() {
		bottomSheet = RouteBottomSheetViewController()
		addChild(bottomSheet)
		view.addSubview(bottomSheet.view)
		bottomSheet.didMove(toParent: self)
		
		bottomSheet.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bottomSheet.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bottomSheet.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bottomSheet.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			bottomSheet.view.heightAnchor.constraint(equalToConstant: 300)
		])
	}
	
}
