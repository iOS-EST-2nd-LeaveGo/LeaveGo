//
//  TimeInterval+Formatting.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/16/25.
//
import Foundation

fileprivate let formatter: DateComponentsFormatter = {
	// calendar - locale 방식
	var calendar = Calendar.current
	calendar.locale = Locale(identifier: "ko_KR")
	
	let f = DateComponentsFormatter()
	f.calendar = calendar
	f.allowedUnits = [.hour, .minute]
	f.unitsStyle = .full
	
	return f
}()

extension TimeInterval {
	var timeString: String? {
		let comp = DateComponents(second: Int(self))
		
		return formatter.string(from: comp)
	}
}

