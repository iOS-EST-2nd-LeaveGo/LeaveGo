//
//  Stop.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

struct Stop {
	enum Kind {
		case currentLocation
		case destination
	}
	let kind: Kind
	let name: String
	let iconName: String
	let color: UIColor
}
