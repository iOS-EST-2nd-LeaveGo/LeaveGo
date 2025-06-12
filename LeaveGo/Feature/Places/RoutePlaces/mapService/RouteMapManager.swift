//
//  RouteMapManager.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/12/25.
//

import Foundation
import MapKit
import CoreLocation

final class RouteMapManager: NSObject {
	private let mapView: MKMapView
	private let locationManager = CLLocationManager()
	
	private let startCoordinate = CLLocationCoordinate2D(latitude: 37.498362, longitude: 127.027603)
	private let destCoordinate  = CLLocationCoordinate2D(latitude: 37.294064, longitude: 127.202599)
	
	init(mapView: MKMapView) {
		self.mapView = mapView
		super.init()
		self.mapView.delegate = self
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		mapView.showsUserLocation = true
	}
	
	func drawRoute() {
		let start = MKPlacemark(coordinate: startCoordinate)
		let dest  = MKPlacemark(coordinate: destCoordinate)
		
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: start)
		request.destination = MKMapItem(placemark: dest)
		request.transportType = .automobile
		
		let directions = MKDirections(request: request)
		
		Task {
			do {
				let result = try await directions.calculate()
				guard let route = result.routes.first else { return }
				
				mapView.removeOverlays(mapView.overlays)
				mapView.addOverlay(route.polyline)
				
				let region = MKCoordinateRegion(route.polyline.boundingMapRect)
				await mapView.setRegion(region, animated: true)
			} catch {
				print("경로 계산 실패: \(error)")
			}
		}
	}
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
