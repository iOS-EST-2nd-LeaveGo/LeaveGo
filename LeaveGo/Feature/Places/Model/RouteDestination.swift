//
//  RouteDestination.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/16/25.
//

import Foundation
import CoreLocation

/// 경로 화면에 전달할 최소 정보
struct RouteDestination {
	let title: String
	let coordinate: CLLocationCoordinate2D
}
