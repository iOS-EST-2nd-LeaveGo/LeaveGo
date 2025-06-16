//
//  RouteMapManager.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/12/25.
//

import Foundation
import MapKit
import CoreLocation

enum RouteError: Error {
	case locationUnavailable
	case noRoutes
}

final class RouteMapManager: NSObject {
	private let mapView: MKMapView
	private let locationManager = CLLocationManager()
	
	//private let startCoordinate = CLLocationCoordinate2D(latitude: 37.498362, longitude: 127.027603)
	var startPlacemark: MKPlacemark? {
		guard let coord = locationManager.location?.coordinate else {
			return nil
		}
		return MKPlacemark(coordinate: coord)
	}
	// TODO: - 차후에 목적지 고정 좌표를 장소목록 세그먼트의 MapVC의 DetailViewController에서 받아와야 함
	private let destCoordinate  = CLLocationCoordinate2D(latitude: 37.294064, longitude: 127.202599)
	
	/// 목적지 고정 좌표를 MKPlacemark로 변환
	var destPlacemark: MKPlacemark {
		MKPlacemark(coordinate: destCoordinate)
	}
	
	init(mapView: MKMapView) {
		self.mapView = mapView
		super.init()
		self.mapView.delegate = self
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		
		mapView.showsUserLocation = true
	}
	
	func calculateRoutes(transportType: MKDirectionsTransportType = .automobile) async throws -> [MKRoute] {
		guard let start = startPlacemark else {
			throw RouteError.locationUnavailable
		}
		let dest = destPlacemark

		var request = MKDirections.Request()
		request.source = MKMapItem(placemark: start)
		request.destination = MKMapItem(placemark: dest)
		request.transportType = transportType
		request.requestsAlternateRoutes = true
		
		let directions = MKDirections(request: request)
		let response   = try await directions.calculate()
		return response.routes
	}

	/// 선택된 경로에 대한 MKPolyline 그리기
	/// - Parameter route: 경로수단 옵션
	func drawRoute(_ route: MKRoute) {
		mapView.removeOverlays(mapView.overlays)
		mapView.addOverlay(route.polyline)
		let region = MKCoordinateRegion(route.polyline.boundingMapRect)
		mapView.setRegion(region, animated: true)
	}
	
//	func calculateAndDrawFirstRoute() async throws {
//		let routes = try await calculateRoutes()
//		guard let first = routes.first else {
//			throw RouteError.noRoutes
//		}
//		drawRoute(first)
//	}
}

extension RouteMapManager: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let r = MKPolylineRenderer(overlay: overlay)
		r.strokeColor = .systemOrange
		r.lineWidth = 8
		return r
	}
}

extension RouteMapManager: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedWhenInUse {
			mapView.showsUserLocation = true
		}
	}
}
