//
//  RouteOptions.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/16/25.
//
import Foundation
import MapKit

struct RouteOptions {
	let start: CLPlacemark?
	let dest:  CLPlacemark?
	let options: [MKRoute]
}
