//
//  PlaceRouteViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit
import MapKit

/// 장소목록 탭바 메뉴 화면 구성 중 - 경로 찾기 버튼 누르면 나오는 경로 설정 화면
class PlaceRouteViewController: UIViewController, RouteBottomSheetViewControllerDelegate {
	
	@IBOutlet weak var locationContainer: UIView!
	@IBOutlet weak var routeMapView: MKMapView!
	
	private lazy var mapManager: RouteMapManager = {
		RouteMapManager(mapView: routeMapView)
	}()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupMapViewGesture()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presentBottomSheet()
	}
	
	private func setupUI() {
		locationContainer.layer.cornerRadius = 10
		locationContainer.clipsToBounds = true
	}
	
	private func setupMapViewGesture() {
		routeMapView.isZoomEnabled = true
		routeMapView.isScrollEnabled = true
		routeMapView.isRotateEnabled = true
		routeMapView.isPitchEnabled = true
		routeMapView.isUserInteractionEnabled = true
		
	}

	
	private func presentBottomSheet() {
		let sheetVC = RouteBottomSheetViewController()
		sheetVC.delegate = self
		sheetVC.modalPresentationStyle = .pageSheet
		sheetVC.isModalInPresentation = true

		if let sheet = sheetVC.sheetPresentationController {
			let customDetent = UISheetPresentationController.Detent.custom(resolver: { context in
				return 0.3 * context.maximumDetentValue
			})

			sheet.detents = [customDetent, .large()]
			sheet.largestUndimmedDetentIdentifier = .medium
			sheet.prefersGrabberVisible = true
			sheet.preferredCornerRadius = 24
			sheet.prefersScrollingExpandsWhenScrolledToEdge = true
		}

		present(sheetVC, animated: true)
	}
	
	
	func didTapCarButton() {
		mapManager.drawRoute()
	}
	
}


extension PlaceRouteViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true 
	}
}
