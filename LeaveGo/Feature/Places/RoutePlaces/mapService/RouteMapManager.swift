//
//  RouteMapManager.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/12/25.
//

import Foundation
import MapKit
import CoreLocation

enum RouteError: Error {
	case locationUnavailable
	case noRoutes
}

/// 경로 설정 서비스매니저
final class RouteMapManager: NSObject {
	private let mapView: MKMapView
	private let locationManager = CLLocationManager()

	var startPlacemark: MKPlacemark? {
		guard let coord = locationManager.location?.coordinate else {
			return nil
		}
		return MKPlacemark(coordinate: coord)
	}

	private let destination: RouteDestination
	
	/// 목적지 고정 좌표를 MKPlacemark로 변환
	var destPlacemark: MKPlacemark {
		return MKPlacemark(coordinate: destination.coordinate)
	}
	
	init(mapView: MKMapView, destination: RouteDestination) {
		self.mapView = mapView
		self.destination = destination
		super.init()
		self.mapView.delegate = self
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		
		mapView.showsUserLocation = true
	}
	
	
	/// 교통수단 이동경로 계산
	/// - Parameter transportType: any(가능한 교통수단 모두) 타입
	/// - Returns: 경로 정보
	func calculateRoutes(
		transportType: MKDirectionsTransportType = .any
		) async throws -> [MKRoute] {
			guard let start = startPlacemark else {
				throw RouteError.locationUnavailable
			}

			let request = MKDirections.Request()
			request.source = MKMapItem(placemark: start)
			request.destination = MKMapItem(placemark: destPlacemark)
			request.transportType = transportType
			request.requestsAlternateRoutes = true

			let response = try await MKDirections(request: request).calculate()
			guard !response.routes.isEmpty else {
				throw RouteError.noRoutes
			}
			return response.routes
		}

		// MARK: – Convenience Wrappers

		/// 자동차 전용 경로
		func calculateDrivingRoutes() async throws -> [MKRoute] {
			try await calculateRoutes(transportType: .automobile)
		}

		/// 도보 전용 경로
		func calculateWalkingRoutes() async throws -> [MKRoute] {
			try await calculateRoutes(transportType: .walking)
		}

		/// 대중교통 전용 경로
		func calculateTransitRoutes() async throws -> [MKRoute] {
			try await calculateRoutes(transportType: .transit)
		}

	/// MKRoute 또는 직선 폴리라인을 그리고, safeAreaInsets + bottomSheet 높이 기반으로 padding 적용
	/// - Parameters:
	///   - route: calculateRoutes() 결과로 얻은 MKRoute. nil 이면 테스트용 직선 폴리라인을 그림.
	///   - bottomSheetHeight: 바텀시트가 차지하는 높이 (뷰컨에서 sheetVC.view.frame.height 로 전달)
	func drawRoute(_ route: MKRoute? = nil,
				   bottomSheetHeight: CGFloat? = nil) {
		// 1) 기존 오버레이 제거
		mapView.removeOverlays(mapView.overlays)
		
		// 2) Polyline 준비
		let poly: MKPolyline
		if let r = route {
			poly = r.polyline
		} else if let start = startPlacemark {
			let coords = [ start.coordinate, destination.coordinate ]
			poly = MKPolyline(coordinates: coords, count: coords.count)
		} else {
			return
		}
		
		// 3) 지도에 추가
		mapView.addOverlay(poly)
		
		// 4) screen focus with safeAreaInsets + bottomSheetHeight
		let rect = poly.boundingMapRect
		let safe = mapView.safeAreaInsets
		let extra: CGFloat = 16
		
		// bottom inset: safe.bottom + extra + optional sheet height
		let bottomInset = safe.bottom + extra + (bottomSheetHeight ?? 0)
		
		let insets = UIEdgeInsets(
			top:    safe.top    + extra,
			left:   safe.left   + extra,
			bottom: bottomInset,
			right:  safe.right  + extra
		)
		mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
	}
}

extension RouteMapManager: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let r = MKPolylineRenderer(overlay: overlay)
		r.strokeColor = .myAccent
		r.lineWidth = 8
		return r
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is MKUserLocation else {
			return nil
		}
		
		let reuseID = "userLocationMarker"
		let markerView: MKMarkerAnnotationView
		if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
			as? MKMarkerAnnotationView {
			markerView = dequeued
			markerView.annotation = annotation
		} else {
			markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
		}
		

		markerView.markerTintColor = .myAccent
		markerView.glyphImage = .none
		markerView.glyphTintColor = .white
		markerView.animatesWhenAdded = true
		markerView.canShowCallout = false
		
		return markerView
	}
}

extension RouteMapManager: CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedWhenInUse {
			mapView.showsUserLocation = true
		}
	}
}

extension RouteMapManager {
	
	/// 좌표를 실제 주소로 변환하여 MKPlacemark 생성
	private func createPlacemarkWithAddress(coordinate: CLLocationCoordinate2D, name: String?) async -> MKPlacemark {
		let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		
		do {
			let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
			if let placemark = placemarks.first {
				// CLPlacemark를 MKPlacemark로 변환
				let mkPlacemark = MKPlacemark(placemark: placemark)
				return mkPlacemark
			}
		} catch {
			print("Geocoding 실패: \(error)")
		}
		
		// 실패 시 기본 MKPlacemark 반환
		return MKPlacemark(coordinate: coordinate)
	}
	
	/// 개선된 경로 계산 (실제 주소 포함)
	func calculateRoutesWithAddresses(
		transportType: MKDirectionsTransportType = .any
	) async throws -> [MKRoute] {
		guard let userCoord = locationManager.location?.coordinate else {
			throw RouteError.locationUnavailable
		}
		
		// 현재 위치와 목적지의 실제 주소 정보 가져오기
		async let startPlacemark = createPlacemarkWithAddress(
			coordinate: userCoord,
			name: "나의 위치"
		)
		async let destPlacemark = createPlacemarkWithAddress(
			coordinate: destination.coordinate,
			name: destination.title
		)
		
		let request = MKDirections.Request()
		
		let sourceItem = MKMapItem(placemark: await startPlacemark)
		sourceItem.name = "나의 위치"
		
		let destItem = MKMapItem(placemark: await destPlacemark)
		destItem.name = destination.title
		
		request.source = sourceItem
		request.destination = destItem
		request.transportType = transportType
		request.requestsAlternateRoutes = true
		
		let response = try await MKDirections(request: request).calculate()
		guard !response.routes.isEmpty else {
			throw RouteError.noRoutes
		}
		return response.routes
	}
}
