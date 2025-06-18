//
//  RouteOptions.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/16/25.
//
import Foundation
import MapKit

struct RouteOptions {
	let start: CLPlacemark?
	let dest:  CLPlacemark?
	let options: [MKRoute]
}
