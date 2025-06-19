//
//  MapViewController.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//
import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {
	
	// MARK: Properties
	private var currentLocation: CLLocationCoordinate2D?
	
	private var didSetInitialRegion = false
	var isSearching = false
	private var initialCenterLocation = false

	private var centerPosition: CLLocationCoordinate2D? = LocationManager.shared.currentLocation
	
	// UI
	var mapView: MKMapView!
	var userLocationButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .white
		button.layer.cornerRadius = 20
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 2)
		button.layer.shadowOpacity = 0.5
		button.layer.shadowRadius = 3
		return button
	}()
	
	let userLocationImageView = UIImageView(image: UIImage(named: "btn_focus"))
	
	var currentPlaceModel: [PlaceModel]? {
		didSet {
			addAnnotation()
		}
	}
	
	// PlacesVC에서 전달받은 선택된 하나의 데이터 타입형태
	var selectedPlace: PlaceModel?
	
	// MARK: LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(locationUpdate(_:)),
			name: .locationDidUpdate,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(headingUpdate(_:)),
			name: .headingDidUpdate,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(locationError(_:)),
			name: .locationUpdateDidFail,
			object: nil
		)
		
		// 설정 커스터마이징
		LocationManager.shared.setConfiguration { manager in
			manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
			manager.distanceFilter = kCLDistanceFilterNone
		}
		
		// 위치 업데이트 추적 시작
		LocationManager.shared.startUpdating()


	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
        setupMapView()
        addTarget()
        configureSubviews()
        addAnnotation()


		if var center = centerPosition {
			
			if !initialCenterLocation {
				center.latitude -= 0.001
				initialCenterLocation = true
			}
			
			//            center.latitude -= 0.001
			let region = MKCoordinateRegion(center: center, latitudinalMeters: 450, longitudinalMeters: 450)
			mapView.setRegion(region, animated: false)
			didSetInitialRegion = true
		}
		
		// 상위 뷰가 준 selectedPlace 처리
		if let place = selectedPlace {
			focusMap(on: place)
			showDetailSheet(for: place)
			selectedPlace = nil
		}
	}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 리소스 정리
        mapView.removeFromSuperview() // 필요 시
        NotificationCenter.default.removeObserver(self)
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
		print("MapViewController, 옵저버 해제 완료")
	}
	
	// 선택한 PlaceListCell의 장소 좌표로 이동
	func focusMap(on place: PlaceModel, verticalOffset: CGFloat = 150) {
		let coord = CLLocationCoordinate2D(
			latitude: place.latitude,
			longitude: place.longitude
		)
		
		let originalPoint = mapView.convert(coord, toPointTo: mapView)
		
		let adjustedPoint = CGPoint(
			x: originalPoint.x,
			y: originalPoint.y + verticalOffset
		)
		
		let adjustedCoord = mapView.convert(adjustedPoint, toCoordinateFrom: mapView)
		
		let region = MKCoordinateRegion(
			center: adjustedCoord,
			latitudinalMeters: 450,
			longitudinalMeters: 450
		)
		
		mapView.setRegion(region, animated: true)
	}
	
	// 위치 변경 될 때
	@objc private func locationUpdate(_ notification: Notification) {
		guard let coordinate = notification.object as? CLLocationCoordinate2D else { return }
		currentLocation = coordinate
		
		if !didSetInitialRegion {
			var center = coordinate
			center.latitude -= 0.001
			let region = MKCoordinateRegion(center: center, latitudinalMeters: 450, longitudinalMeters: 450)
			self.mapView.setRegion(region, animated: false)
			self.didSetInitialRegion = true
		}
	}
	
	@objc private func headingUpdate(_ notification: Notification) {
		guard let heading = notification.object as? CLHeading else { return }
		let rotationAngle = (heading.trueHeading * Double.pi) / 180.0
		if let annotationView = mapView.view(for: mapView.userLocation) {
			annotationView.transform = CGAffineTransform(rotationAngle: rotationAngle)
		}
	}
	
	// 위치 추적 실패
	@objc private func locationError(_ notification: Notification) {
		if let error = notification.object as? Error {
			print("위치 추적 실패: \(error.localizedDescription)")
		}
	}
	
	public func addAnnotation() {
		guard let mapView = self.mapView else { return }
		guard let placeModelList = self.currentPlaceModel else { return }
		
		// 기존 어노테이션 제거 (사용자 위치 어노테이션 제외)
		mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
		
		let annotations = placeModelList.compactMap {
			//print("lat: \($0.latitude), lon: \($0.longitude)")
			return $0.toAnnotationModel()
		}
		
		mapView.addAnnotations(annotations)
	}
	
	func addTarget() {
		userLocationButton.addTarget(self, action: #selector(setMapRegion), for: .touchUpInside)
	}
	
	// MARK: - Action
	@objc func setMapRegion() {
		self.userLocationImageView.image = self.userLocationImageView.image?.withTintColor(.systemBlue)
		
		var coordiCenterLa = mapView.userLocation.coordinate.latitude
		let coordiCenterLo = mapView.userLocation.coordinate.longitude
		coordiCenterLa -= 0.001
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo),
										latitudinalMeters: 450, longitudinalMeters: 450)
		mapView.setRegion(region, animated: true)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // 삭제하는게 좋겠음 아니면 completion 처리하든가
			self.userLocationImageView.image = self.userLocationImageView.image?.withTintColor(.black)
		}
	}
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
	
	func setupMapView() {
		mapView = MKMapView(frame: view.frame)
		
		mapView.delegate = self
		mapView.showsUserLocation = true // 사용자 위치
		
		mapView.register(PlaceAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: String(
							describing: PlaceAnnotationModel.self))
		
		mapView.register(
			PlaceClusterAnnotationView.self,
			forAnnotationViewWithReuseIdentifier: PlaceClusterAnnotationView.identifier
		)
	}
	
	// 척도 범위 설정
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		// scale of map
		//        let center = mapView.userLocation.coordinate
		
		centerPosition = mapView.region.center
		
		let zoomLevel = log2(360 *
							 (Double(mapView.frame.size.width/256) /
							  mapView.region.span.longitudeDelta))
		
		if zoomLevel < 8 {
			let limitSpan = MKCoordinateSpan(latitudeDelta: 1.40625, longitudeDelta: 1.40625)
			
			guard let movePosition = centerPosition else { return }
			let region = MKCoordinateRegion(center: movePosition, span: limitSpan)
			mapView.setRegion(region, animated: true)
		}
		
		guard !isSearching else { return }
		
		// 지도 이동 Notification
		NotificationCenter.default.post(name: .mapDidMove, object: centerPosition)
	}
	
	/// 어노테이션 탭했을 때 호출
	/// - Parameters:
	///   - mapView: 어노테이션 뷰가 선택된 MKMapView 인스턴스
	///   - view: 선택된 어노테이션 인스턴스
	///   뷰의 `annotation`이 `PlaceAnnotationModel`인 경우에만 처리
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotation = view.annotation as? PlaceAnnotationModel else { return }
		mapView.deselectAnnotation(annotation, animated: false)
		
		var coordiCenterLa = annotation.coordinate.latitude
		let coordiCenterLo = annotation.coordinate.longitude
		coordiCenterLa -= 0.0015
		
		let coordinate = CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo)
		let region = MKCoordinateRegion(center: coordinate,
										latitudinalMeters: 450, longitudinalMeters: 450)
		mapView.setRegion(region, animated: true)
		
		if let presented = presentedViewController {
			presented.dismiss(animated: false) { [weak self] in
				self?.presentDetail(for: annotation)
			}
		} else {
			presentDetail(for: annotation)
		}
	}
	
	private func presentDetail(for annotation: PlaceAnnotationModel) {
		let sb = UIStoryboard(name: String(describing: Planner.self), bundle: nil)
		guard let detailVC = sb.instantiateViewController(
			withIdentifier: String(describing: PlaceDetailModalViewController.self)
		) as? PlaceDetailModalViewController else {
			return
		}
		
		detailVC.place = annotation.placeModel
		detailVC.delegate = self
		
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			// ===== iPad: 사이드바처럼 child VC로 추가 =====
			addChild(detailVC)
			view.addSubview(detailVC.view)
			detailVC.didMove(toParent: self)
			
			// 오토레이아웃으로 왼쪽에 고정
			detailVC.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				detailVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				detailVC.view.topAnchor.constraint(equalTo: view.topAnchor),
				detailVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				detailVC.view.widthAnchor.constraint(equalToConstant: 400) // 너비는 필요에 따라 조정
			])
		} else {
			// ===== iPhone: pageSheet로 모달 프레젠트 =====
			detailVC.modalPresentationStyle = .pageSheet
			if let sheet = detailVC.sheetPresentationController {
				sheet.detents = [
					.custom { _ in 320 },
					.medium(),
					.large()
				]
				sheet.prefersGrabberVisible = true
			}
			present(detailVC, animated: true)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			let annotationView = MKAnnotationView(
				annotation: annotation,
				reuseIdentifier: "userlocation"
			)
			annotationView.image = UIImage(named: "img_userAnnotation")
			annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 25*1.44)
			annotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.63)
			
			return annotationView
		}
		
		// 클러스터 어노테이션 처리
		if let cluster = annotation as? MKClusterAnnotation {
			let cv = mapView.dequeueReusableAnnotationView(
				withIdentifier: PlaceClusterAnnotationView.identifier,
				for: cluster
			) as! PlaceClusterAnnotationView
			let firstCat1 = cluster.memberAnnotations
				.compactMap { ($0 as? PlaceAnnotationModel)?.cat1 }
				.first
			cv.configure(with: firstCat1, count: cluster.memberAnnotations.count)
			return cv
		}
		
		// 장소 annotation 설정
		guard let placeAnnotation = annotation as? PlaceAnnotationModel else {
			return nil
		}
		
		var annotationView = mapView.dequeueReusableAnnotationView(
			withIdentifier: PlaceAnnotationView.identifier
		) as? PlaceAnnotationView
		
		if annotationView == nil {
			annotationView = PlaceAnnotationView(
				annotation: placeAnnotation,
				reuseIdentifier: PlaceAnnotationView.identifier
			)
			annotationView?.canShowCallout = false
			annotationView?.contentMode = .scaleAspectFit
		} else {
			annotationView?.annotation = placeAnnotation
		}
		
		// clusteringIdentifier는 PlaceAnnotationView 내부의 configure에서 이미 지정됨 :contentReference[oaicite:0]{index=0}
		annotationView?.configure(with: placeAnnotation)
		return annotationView
	}
	
}

extension MapViewController: LayoutSupport {
	func addSubviews() {
		self.view.addSubview(mapView)
		mapView.addSubview(userLocationButton)
		//mapView.addSubview(bottomSheetView)

		userLocationButton.addSubview(userLocationImageView)
	}

	func setupSubviewsConstraints() {
		mapView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		userLocationButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userLocationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
			userLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
			userLocationButton.heightAnchor.constraint(equalToConstant: 40),
			userLocationButton.widthAnchor.constraint(equalToConstant: 40)
		])

		userLocationImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			userLocationImageView.topAnchor.constraint(equalTo: userLocationButton.topAnchor, constant: 8),
			userLocationImageView.bottomAnchor.constraint(equalTo: userLocationButton.bottomAnchor, constant: -8),
			userLocationImageView.leadingAnchor.constraint(equalTo: userLocationButton.leadingAnchor, constant: 8),
			userLocationImageView.trailingAnchor.constraint(equalTo: userLocationButton.trailingAnchor, constant: -8)
		])
	}
}

extension MapViewController: ModalPresentable {
	
	func showDetailSheet(for place: PlaceModel) {
		presentPlaceDetail(for: place)
	}
	
	func presentPlaceDetail(for place: PlaceModel) {
		let annotation = PlaceAnnotationModel(place: place)
		// iPad/iPhone 공통 분기 로직
		presentDetail(for: annotation)
	}
}

extension MapViewController: PlaceDetailModalDelegate {
	func placeDetailModalDidTapFindRouteButton(
		_ controller: PlaceDetailModalViewController,
		didSelectRoute destination: RouteDestination
	) {
		if UIDevice.current.userInterfaceIdiom == .pad {
			controller.willMove(toParent: nil)
			controller.view.removeFromSuperview()
			controller.removeFromParent()
		}
		// 공통 경로 화면으로 이동
		showRouteScreen(destination: destination)
	}
}

