//
//  RouteDestination.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/16/25.
//

import Foundation
import CoreLocation

/// 경로 화면에 전달할 최소 정보
struct RouteDestination {
	let title: String
	let coordinate: CLLocationCoordinate2D
	let address: String?
	
	init(place: PlaceModel) {
		self.title = place.title
		self.coordinate = CLLocationCoordinate2D(
			latitude: place.latitude,
			longitude: place.longitude
		)
		
		var addressComponents: [String] = []
		if let add1 = place.add1, !add1.isEmpty {
			addressComponents.append(add1)
		}
		if let add2 = place.add2, !add2.isEmpty {
			addressComponents.append(add2)
		}
		self.address = addressComponents.isEmpty ? nil : addressComponents.joined(separator: " ")
	}
}
