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
    static let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
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
    var annotationList: [PlaceAnnotationModel] = []
    
    // Sample Data
    var pinModels = [
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3167000, longitude: 127.4435000), title: "1", subtitle: "대전 동구 천동 대전로 0번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3167000, longitude: 127.4400000), title: "2", subtitle: "대전 동구 천동 대전로 542번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3141000, longitude: 127.4455000), title: "3", subtitle: "대전 동구 천동 대전로 3번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3198000, longitude: 127.4482000), title: "4", subtitle: "대전 동구 천동 대전로 4번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3164000, longitude: 127.4411000), title: "5", subtitle: "대전 동구 천동 대전로 5번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3346000, longitude: 127.4556000), title: "6", subtitle: "대전 동구 천동 대전로 1번길"),
        PlaceAnnotationModel(coordinate: CLLocationCoordinate2D(latitude: 36.3368000, longitude: 127.4567000), title: "7", subtitle: "대전 동구 용운동 대학로 3번길")
    ]
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupCLLocationManager()
        self.setupMapView()
        
        self.addTarget()
//        self.addTestAnnotation()
        
        self.configureSubviews()
    
        
        guard let placeModelList = self.placeModelList else { return }
        let annotations = placeModelList.compactMap {
            
            print("lat: \($0.latitude), lon: \($0.longitude)")
            return $0.toAnnotationModel()
        }
        
        mapView.addAnnotations(annotations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didSetInitialRegion {
            LocationManager.shared.fetchLocation { [weak self] Coordinate, error in
                guard let self = self else { return }
                guard let center = Coordinate else { return }
                
                let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.mapView.setRegion(region, animated: false)
                self.didSetInitialRegion = true
            }
        }
    }
    
    func addTestAnnotation() {
        _=pinModels.map {
            mapView.addAnnotation($0)
        }
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
        
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier:
                                                PlaceAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        let annotationImage: UIImage!
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        
        
        annotationImage = UIImage(systemName: "pin.circle.fill")
        annotationImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
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

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func setupCLLocationManager() {
        MapViewController.locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didSetInitialRegion else { return }
        guard let location = locations.last else { return }
        
        var coordiCenterLa = location.coordinate.latitude
        coordiCenterLa -= 0.001
        let coordiCenterLo = location.coordinate.longitude
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo),
                                        latitudinalMeters: 450, longitudinalMeters: 450)
        mapView.setRegion(region, animated: false)
        didSetInitialRegion = true
        
        // 위치 업데이트 종료
        MapViewController.locationManager.stopUpdatingLocation()
    }
    
    /// 사용자의 방향에따라 annotaion의 방향을 변경
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rotationAngle = (newHeading.trueHeading * Double.pi) / 180.0
        if let annotationView = mapView.view(for: mapView.userLocation) {
            annotationView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
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
