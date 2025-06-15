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
    var didSetInitialRegion = false

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
    let userLocationImageView = UIImageView(image: UIImage(named: "btn_ focus"))
    let bottomSheetView: BottomSheetView = {
        let btsView = BottomSheetView()

        return btsView
    }()

    var placeModelList: [PlaceModel]? // NetworkManager로 부터 받아온 PlaceList

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

        setupMapView()
        addTarget()
        configureSubviews()
        addAnnotation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if var center = LocationManager.shared.currentLocation {
            center.latitude -= 0.001
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 450, longitudinalMeters: 450)
            mapView.setRegion(region, animated: false)
            didSetInitialRegion = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("MapViewController, 옵저버 해제 완료")
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

    func addAnnotation() {
        guard let placeModelList = self.placeModelList else { return }
        let annotations = placeModelList.compactMap {

            print("lat: \($0.latitude), lon: \($0.longitude)")
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
        //      bottomSheetView.mode = .tip // sheetview dismiss

        // bottomSheetView.hiddenDetailView()
        //      mapView.removeMapViewOverlayOfLast() // 화면에 나타난 경로 삭제

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
    }

    // 척도 범위 설정
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // scale of map
        let center = mapView.userLocation.coordinate
        let zoomLevel = log2(360 *
                             (Double(mapView.frame.size.width/256) /
                              mapView.region.span.longitudeDelta))

        if zoomLevel < 8 {
            let limitSpan = MKCoordinateSpan(latitudeDelta: 1.40625, longitudeDelta: 1.40625)
            let region = MKCoordinateRegion(center: center, span: limitSpan)
            mapView.setRegion(region, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자 현재위치의 view setting
        if annotation is MKUserLocation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userlocation")
            annotationView.image = UIImage(named: "img_userlocation")
            annotationView.layer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView.layer.shadowColor = UIColor.orange.cgColor
            annotationView.layer.shadowOffset = CGSize(width: 1, height: 1)
            annotationView.layer.shadowOpacity = 0.5
            annotationView.layer.shadowRadius = 5
            // ios 16 이상부터는 layer없이 바로 anchorpoint를 설정할 수 있음!
            return annotationView
        }

        guard let annotation = annotation as? PlaceAnnotationModel else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:
                                                                    PlaceAnnotationView.identifier)
        as? PlaceAnnotationView

        if annotationView == nil {
            annotationView = PlaceAnnotationView(annotation: annotation, reuseIdentifier:
                                                    PlaceAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation

        }


        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)

        let annotationImage = UIImage(systemName: "pin.circle.fill")

        annotationImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage

        annotationView?.titleLabel.text = annotation.title

        return annotationView
    }

    /// 경로위에 표시되는 line UI를 정의
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.lineWidth = 5.0
            polylineRenderer.strokeColor = .blue

            return polylineRenderer
        }

        return MKOverlayRenderer()
    }

}

extension MapViewController: LayoutSupport {

    func addSubviews() {
        self.view.addSubview(mapView)
        mapView.addSubview(userLocationButton)
        mapView.addSubview(bottomSheetView)

        userLocationButton.addSubview(userLocationImageView)
    }

    func setupSubviewsConstraints() {
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

        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSheetView.topAnchor.constraint(equalTo: mapView.topAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            bottomSheetView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor)
        ])
    }

}
