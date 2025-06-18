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
	@IBOutlet weak var routeMapView: MKMapView!
	
	var destination: RouteDestination?
	private weak var sheetVC: RouteBottomSheetViewController?
	
	private var cachedRoutes: [MKRoute] = []
	private var routesData: RouteOptions?
	
	let userLocationImageView = UIImageView(image: UIImage(named: "btn_focus"))
	
	private lazy var mapManager: RouteMapManager = {
		guard let dest = destination else {
			fatalError("📍destination을 반드시 셋업해야 합니다!")
		}
		return RouteMapManager(
			mapView: routeMapView,
			destination: dest
		)
	}()
	
	private let currentLocationButton: UIButton = {
		let btn = UIButton()
		btn.backgroundColor = .white
		btn.layer.cornerRadius = 25
		btn.layer.shadowColor = UIColor.black.cgColor
		btn.layer.shadowOpacity = 0.1
		btn.layer.shadowOffset = CGSize(width: 0, height: 2)
		btn.layer.shadowRadius = 4
		return btn
	}()
	
	private let currentLocationImage: UIImageView = {
		let raw = UIImage(named: "btn_focus")?
			.withRenderingMode(.alwaysTemplate)
		let iv = UIImageView(image: raw)
		iv.contentMode = .scaleAspectFit
		iv.tintColor = .black
		return iv
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let dest = destination else {
			assertionFailure("Destination not set before presenting PlaceRouteViewController")
			return
		}
		
		setupMapViewGesture()
		setupUserLocationControl()
		
		routeMapView.showsUserLocation = true
		routeMapView.userLocation.title = "내 위치"
		routeMapView.delegate = mapManager
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(debugZoom(_:)))
		routeMapView.addGestureRecognizer(pinch)
		setupNavBar(with: dest.title)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presentBottomSheet()
		// 초기 접근시 자동차 경로로 표시
		calculateAndShowRoute(.automobile)
	}
	
	private func setupUserLocationControl() {
		view.addSubview(currentLocationButton)
		currentLocationButton.addSubview(currentLocationImage)
		
		currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
		currentLocationImage.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			currentLocationButton.leadingAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.leadingAnchor,
				constant: 24
			),
			currentLocationButton.bottomAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.bottomAnchor,
				constant: -200
			),
			currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
			currentLocationButton.heightAnchor.constraint(equalToConstant: 50)
		])
		
		NSLayoutConstraint.activate([
			currentLocationImage.topAnchor.constraint(
				equalTo: currentLocationButton.topAnchor,
				constant: 10
			),
			currentLocationImage.bottomAnchor.constraint(
				equalTo: currentLocationButton.bottomAnchor,
				constant: -10
			),
			currentLocationImage.leadingAnchor.constraint(
				equalTo: currentLocationButton.leadingAnchor,
				constant: 10
			),
			currentLocationImage.trailingAnchor.constraint(
				equalTo:currentLocationButton.trailingAnchor,
				constant: -10
			)
		])
		
		currentLocationButton.addTarget(self,
										action: #selector(findUserLocation(_:)),
										for: .touchUpInside)
	}
	
	
	
	@objc func findUserLocation(_ sender: UIButton) {
		guard let userCoord = mapManager.startPlacemark?.location?.coordinate else {
			print("사용자 위치를 얻을 수 없습니다.")
			return
		}
		
		sender.isEnabled = false
		userLocationImageView.tintColor = .systemBlue
		
		CATransaction.begin()
		CATransaction.setAnimationDuration(0.6)
		CATransaction.setCompletionBlock {
			let region = MKCoordinateRegion(
				center: userCoord,
				latitudinalMeters: 450,
				longitudinalMeters: 450
			)
			self.routeMapView.setRegion(region, animated: true)
			sender.isEnabled = true
			self.userLocationImageView.tintColor = nil
		}
		
		let offset = CLLocationCoordinate2D(
			latitude: userCoord.latitude - 0.001,
			longitude: userCoord.longitude
		)
		let offsetRegion = MKCoordinateRegion(
			center: offset,
			latitudinalMeters: 450,
			longitudinalMeters: 450
		)
		routeMapView.setRegion(offsetRegion, animated: true)
		CATransaction.commit()
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
	
	private func calculateAndShowRoute(_ transportType: MKDirectionsTransportType) {
		Task { @MainActor in
			routeMapView.removeOverlays(routeMapView.overlays)
			
			do {
				let routes: [MKRoute]
				switch transportType {
				case .walking:
					routes = try await mapManager.calculateWalkingRoutes()
				case .transit:
					routes = try await mapManager.calculateTransitRoutes()
				case .automobile:
					routes = try await mapManager.calculateDrivingRoutes()

				default:
					throw RouteError.noRoutes
				}
				
				if routes.isEmpty {
					throw RouteError.noRoutes
				}

				guard let best = routes.first else { print("====경로 없음=== "); return }

				let opts = RouteOptions(
					start: mapManager.startPlacemark,
					dest:  mapManager.destPlacemark,
					options: routes
				)
				cachedRoutes = routes
				routesData   = opts
				sheetVC?.routesData = opts

				let sheetHeight = sheetVC?.view.frame.height ?? 0
				showRouteWithDynamicZoom(best, bottomSheetHeight: sheetHeight)

				sheetVC?.showRoutes(opts)
			} catch RouteError.noRoutes {
				print("RouteError.noRoutes 발생")
				let empty = RouteOptions(
					start: mapManager.startPlacemark,
					dest:  mapManager.destPlacemark,
					options: []
				)
				sheetVC?.routesData = empty
				sheetVC?.showRoutes(empty)
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
	func didTapWalkButton() {
		calculateAndShowRoute(.walking)
	}
	
	func didTapCarButton() {
		calculateAndShowRoute(.automobile)
	}
	
	func didSelectRoute(_ route: MKRoute) {
		//print("=== didSelectRoute called for route === :", route.name)
		let sheetHeight = sheetVC?.view.frame.height ?? 0
		showRouteWithDynamicZoom(route, bottomSheetHeight: sheetHeight)
	}
	
	func didTapTransitButton() {
		calculateAndShowRoute(.transit)
	}
}
