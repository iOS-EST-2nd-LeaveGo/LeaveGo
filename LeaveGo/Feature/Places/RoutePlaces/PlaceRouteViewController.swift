//
//  PlaceRouteViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit
import MapKit

/// 장소목록 탭바 메뉴 화면 구성 중 - 경로 찾기 버튼 누르면 나오는 경로 설정 화면
class PlaceRouteViewController: UIViewController {
	
	@IBOutlet weak var locationContainer: UIView!
	@IBOutlet weak var routeMapView: MKMapView!
	
	var destination: RouteDestination?
	
	private lazy var mapManager: RouteMapManager = {
		RouteMapManager(mapView: routeMapView)
	}()
	
	private weak var sheetVC: RouteBottomSheetViewController?
		
	override func viewDidLoad() {
		super.viewDidLoad()
		// MARK - debug message
		guard let dest = destination else {
			assertionFailure("Destination not set before presenting PlaceRouteViewController")
			return
		}

		setupUI()
		setupMapViewGesture()
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(debugZoom(_:)))
		routeMapView.addGestureRecognizer(pinch)
		setupNavBar(with: dest.title)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presentBottomSheet()
	}
	
	private func setupUI() {
		locationContainer.layer.cornerRadius = 10
		locationContainer.clipsToBounds = true
	}
	
	private func setupNavBar(with title: String) {
		navigationItem.title = title
		
		navigationItem.hidesBackButton = true
		let back = UIBarButtonItem(
			image: UIImage(systemName: "chevron.backward"),
			style: .plain,
			target: self,
			action: #selector(didTapBackButton)
		)
		navigationItem.leftBarButtonItem = back
		
		// 배경색
		navigationController?.navigationBar.barTintColor = .systemBackground
		navigationController?.navigationBar.isTranslucent = false
	}
	
	@objc private func didTapBackButton() {
		navigationController?.popViewController(animated: true)
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
		print("=== Zoom detected: scale = \(gesture.scale)")
	}

	
	private func presentBottomSheet() {
		let vc = RouteBottomSheetViewController()
		vc.delegate = self
		self.sheetVC = vc
		vc.modalPresentationStyle = .pageSheet
		vc.isModalInPresentation = true

		if let sheet = vc.sheetPresentationController {
			let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("collapsed")) { context in
				return 0.45 * context.maximumDetentValue
			}

			sheet.detents = [customDetent, .large()]
			sheet.largestUndimmedDetentIdentifier = .large
			sheet.prefersGrabberVisible = true
			sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			sheet.prefersEdgeAttachedInCompactHeight = true
		}

		present(vc, animated: true)
	}
}


extension PlaceRouteViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension PlaceRouteViewController: RouteBottomSheetViewControllerDelegate {
	func didTapCarButton() {
		Task {
			do {
				let routes = try await mapManager.calculateRoutes()
				guard !routes.isEmpty else { return }
				
				await MainActor.run {
					mapManager.drawRoute(routes[0])
	
					let optionsModel = RouteOptions(
						start: mapManager.startPlacemark,
						dest:  mapManager.destPlacemark,
						options: routes
					)
					self.sheetVC?.showRoutes(optionsModel)
				}
			} catch {
				print("경로 계산 실패:", error)
			}
		}
	}
	
	func didSelectRoute(_ route: MKRoute) {
		print("=== didSelectRoute called for route === :", route.name)
		DispatchQueue.main.async {
			self.mapManager.drawRoute(route)
		}
	}
	
	func didTapBicycleButton() {
		// 아직 자전거 경로 계산 안했으니 빈 배열로 표시
		let emptyModel = RouteOptions(
			start: mapManager.startPlacemark,
			dest:  mapManager.destPlacemark,
			options: []
		)
		sheetVC?.showRoutes(emptyModel)
	}
}
