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
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(debugZoom(_:)))
		routeMapView.addGestureRecognizer(pinch)
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
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(debugZoom(_:)))
		pinch.cancelsTouchesInView = false
		routeMapView.addGestureRecognizer(pinch)
		
	}
	
	@objc private func debugZoom(_ gesture: UIPinchGestureRecognizer) {
		print("📌 Zoom detected: scale = \(gesture.scale)")
	}

	
	private func presentBottomSheet() {
		let sheetVC = RouteBottomSheetViewController()
		sheetVC.delegate = self
		sheetVC.modalPresentationStyle = .pageSheet
		sheetVC.isModalInPresentation = true

		if let sheet = sheetVC.sheetPresentationController {
			let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("collapsed")) { context in
				return 0.3 * context.maximumDetentValue
			}

			sheet.detents = [customDetent, .large()]
			sheet.largestUndimmedDetentIdentifier = .large
			sheet.prefersGrabberVisible = true
			sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			sheet.prefersEdgeAttachedInCompactHeight = true
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
