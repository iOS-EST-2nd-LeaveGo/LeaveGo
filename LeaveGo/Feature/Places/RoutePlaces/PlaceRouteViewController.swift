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
	private weak var sheetVC: RouteBottomSheetViewController?
	
	private var cachedRoutes: [MKRoute] = []
	private var routesData: RouteOptions?
	
	
	private lazy var mapManager: RouteMapManager = {
		guard let dest = destination else {
			fatalError("📍destination을 반드시 셋업해야 합니다!")
		}
		return RouteMapManager(
			mapView: routeMapView,
			destination: dest
		)
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// MARK - debug message
		guard let dest = destination else {
			assertionFailure("Destination not set before presenting PlaceRouteViewController")
			return
		}
		
		setupUI()
		setupMapViewGesture()
		
		routeMapView.delegate = mapManager
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(debugZoom(_:)))
		routeMapView.addGestureRecognizer(pinch)
		setupNavBar(with: dest.title)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presentBottomSheet()
		calculateAndShowCarRoute()
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
		
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = .systemBackground
		appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
		
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.compactAppearance = appearance
		navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
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
	
	func showRouteWithDynamicZoom(_ route: MKRoute, bottomSheetHeight: CGFloat) {
		// 1) polyline 그리기
		routeMapView.addOverlay(route.polyline)
		
		let boundingRect = route.polyline.boundingMapRect
		
		let distanceKm = route.distance / 1_000.0
		let scale = min(max(1.2 + distanceKm * 0.5, 1.2), 3.0)
		
		let dx = boundingRect.width * (scale - 1) / 2
		let dy = boundingRect.height * (scale - 1) / 2
		let expandedRect = boundingRect.insetBy(dx: -dx, dy: -dy)
		
		let basePadding: CGFloat = 20
		let padding = basePadding * scale
		let insets = UIEdgeInsets(
			top: padding,
			left: padding,
			bottom: bottomSheetHeight + padding,
			right: padding
		)
		
		let fitted = routeMapView.mapRectThatFits(expandedRect, edgePadding: insets)
		routeMapView.setVisibleMapRect(fitted, animated: true)
	}
	
	private func presentBottomSheet() {
		guard let dest = destination else {
			assertionFailure("Destination이 설정되지 않은 상태로 시트를 띄우고 있습니다.")
			return
		}
		let vc = RouteBottomSheetViewController()
		vc.delegate = self
		self.sheetVC = vc
		
		vc.configureStops(
			currentLocationName: "나의 위치",
			destinationName: dest.title
		)
		
		vc.routesData = nil
		
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: 왼쪽 사이드뷰에 표시
            addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
            
            // 오토레이아웃으로 왼쪽에 고정
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                vc.view.widthAnchor.constraint(equalToConstant: 400) // 너비는 필요에 따라 조정
            ])
        } else {
            vc.modalPresentationStyle = .pageSheet
            vc.isModalInPresentation = true
            
            if let sheet = vc.sheetPresentationController {
                let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("collapsed")) { context in
                    return 0.3 * context.maximumDetentValue
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
	
	private func calculateAndShowCarRoute() {
		Task {
			do {
				let routes = try await mapManager.calculateRoutes()
				guard let best = routes.first else { return }
				
				let opts = RouteOptions(
					start: mapManager.startPlacemark,
					dest:  mapManager.destPlacemark,
					options: routes
				)
				
				await MainActor.run {
					
					let sheetHeight = sheetVC?.view.frame.height ?? 0
					// 경로 길이만큼 포커싱 줌 아웃 조절
					showRouteWithDynamicZoom(best, bottomSheetHeight: sheetHeight)
					
					self.cachedRoutes = routes
					self.routesData = opts
					self.sheetVC?.routesData = opts
				}
			} catch {
				print("경로 계산 실패:", error)
			}
		}
	}
}


extension PlaceRouteViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension PlaceRouteViewController: RouteBottomSheetViewControllerDelegate {
	func didTapCarButton() {
		if routesData == nil {
			calculateAndShowCarRoute()
			return
		}
		
		if let opts = routesData {
			sheetVC?.showRoutes(opts)
		}
		
		// (선택) polyline도 재초점
		/*
		 if let best = opts.options.first {
		 let sheetH = sheetVC?.view.frame.height ?? 0
		 showRouteWithDynamicZoom(best, bottomSheetHeight: sheetH)
		 }
		 */
	}
	
	func didSelectRoute(_ route: MKRoute) {
		print("=== didSelectRoute called for route === :", route.name)
		let sheetH = sheetVC?.view.frame.height ?? 0
		showRouteWithDynamicZoom(route, bottomSheetHeight: sheetH)
	}
	
	func didTapBicycleButton() {
		// 아직 자전거 경로 계산 안했으니 빈 배열로 표시
		routeMapView.removeOverlays(routeMapView.overlays)
		// 하단 시트엔 빈 옵션만 표시
		let emptyModel = RouteOptions(
			start: mapManager.startPlacemark,
			dest:  mapManager.destPlacemark,
			options: []
		)
		sheetVC?.showRoutes(emptyModel)
	}
}
