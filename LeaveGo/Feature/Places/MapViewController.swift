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
    {
        didSet {
            print("------------------ mapVC placeModelList didSet ------------------")
            print(placeModelList)
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupCLLocationManager()
        self.setupMapView()
        
        self.addTarget()

        self.configureSubviews()
        
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
    
    public func addAnnotation() {
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
    
    func simpleClusterImage(emoji: String) -> UIImage {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            // 배경 원
            let rect = CGRect(origin: .zero, size: size)
            UIColor.white.setFill()
            UIBezierPath(ovalIn: rect).fill()

            // 이모지 중심 배치
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .paragraphStyle: paragraphStyle
            ]
            let textRect = CGRect(x: 0, y: (size.height - 24) / 2, width: size.width, height: 24)
            emoji.draw(in: textRect, withAttributes: attributes)
        }
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
        // 사용자 현재위치 annotation 설정
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
        
        // cluster annotation 설정
        if let cluster = annotation as? MKClusterAnnotation {
            let identifier = "ClusterView"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if clusterView == nil {
                clusterView = MKAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                clusterView?.canShowCallout = false
            } else {
                clusterView?.annotation = cluster
            }
            
            let firstAnnotation = cluster.memberAnnotations.first as? PlaceAnnotationModel
            let cat1 = firstAnnotation?.cat1 ?? "1"
            
            let emoji: String
            switch cat1 {
            case "A01": emoji = "🌿" // 자연
            case "A02": emoji = "🎨" // 예술
            case "A03": emoji = "🏄‍♂️" // 레포츠
            case "A04": emoji = "🛍️" // 쇼핑
            case "A05": emoji = "🍜" // 음식
            case "A06": emoji = "🏨" // 숙박
            case "A07": emoji = "🚅" // 교통
            case "A08": emoji = "🗺️" // 여행사
            case "A09": emoji = "🎆" // 축제
            case "A10": emoji = "🏸" // 레저스포츠
            case "B01": emoji = "⛩️" // 관광지
            case "C01": emoji = "🏛️" // 문화시설
            default: emoji = "📍"
            }
            
            clusterView?.image = simpleClusterImage(emoji: emoji)
            
            return clusterView
        }
        
        // 장소 annotation 설정
        guard let annotation = annotation as? PlaceAnnotationModel else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:
                                                                    PlaceAnnotationView.identifier)
        as? PlaceAnnotationView
        
        if annotationView == nil {
            annotationView = PlaceAnnotationView(annotation: annotation, reuseIdentifier:
                                                PlaceAnnotationView.identifier)
            
            annotationView?.clusteringIdentifier = "\(annotation.areaCode ?? "1")-\(annotation.cat1 ?? "1")"
            
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
            
        }
        
        // annotation view
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        
        let annotationImage = UIImage(systemName: "pin.circle.fill")
        
        annotationImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        if let label = annotationView?.titleLabel {
            label.text = annotation.title ?? ""
        } else {
            print("⚠️ titleLabel is nil")
        }
        
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
