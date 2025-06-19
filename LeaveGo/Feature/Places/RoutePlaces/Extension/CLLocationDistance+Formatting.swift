//
//  CLLocationDistance+Formatting.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/16/25.
//
import Foundation
import CoreLocation

fileprivate let formatter: MeasurementFormatter = {
	let f = MeasurementFormatter()
	f.unitOptions = .naturalScale
	f.locale = Locale(identifier: "ko_kr")
	// 소수점 표시 안되게 함
	f.numberFormatter.maximumFractionDigits = 0
	
	return f
}()

extension CLLocationDistance {
	var distanceString: String? {
		let distance = Measurement(value: self, unit: UnitLength.meters)
		return formatter.string(from: distance)
	}
}
