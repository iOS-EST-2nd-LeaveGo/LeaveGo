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
  var locationManager: CLLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    locationManager.requestWhenInUseAuthorization()
    return locationManager
  }()
  var mapView: MKMapView!
  
  // MARK: LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = MKMapView(frame: view.frame)
    
    setupCLLocationManager()
    setupMapView()
    configureSubviews()
  }
  
}

// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
  
  func setupMapView() {
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

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
  
  func setupCLLocationManager() {
    self.locationManager.delegate = self
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     guard let location = locations.last else { return }
     
     var coordiCenterLa = location.coordinate.latitude
     coordiCenterLa -= 0.001
     let coordiCenterLo = location.coordinate.longitude
     
     let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordiCenterLa, longitude: coordiCenterLo),
                                     latitudinalMeters: 450, longitudinalMeters: 450)
     mapView.setRegion(region, animated: false)
     
     // 위치 업데이트 종료
     self.locationManager.stopUpdatingLocation()
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
    
  }
  
  func setupSubviewsConstraints() {
    print("")
  }
  
}

#Preview {
  MapViewController()
}
