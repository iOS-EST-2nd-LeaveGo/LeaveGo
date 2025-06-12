//
//  RouteSheetPassthroughView .swift
//  LeaveGo
//
//  Created by Nat Kim on 6/12/25.
//

import UIKit

class RouteSheetPassthroughView: UIView {
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let passThroughHeight = bounds.height * 0.2
		let passThroughArea = CGRect(x: 0, y: 0, width: bounds.width, height: passThroughHeight)
		return !passThroughArea.contains(point)
	}
}
