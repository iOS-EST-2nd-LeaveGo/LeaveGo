//
//  StrokedLabel.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/18/25.
//

import UIKit

public class StrokedLabel: UILabel {
	var strokeWidth: CGFloat = 5.0 {
		didSet { setNeedsDisplay() }
	}

	var strokeColor: UIColor = .black {
		didSet { setNeedsDisplay() }
	}
	
	public override func drawText(in rect: CGRect) {
		guard let ctx = UIGraphicsGetCurrentContext(), let _ = self.text else {
			super.drawText(in: rect)
			return
		}

		ctx.setLineWidth(strokeWidth)
		ctx.setLineJoin(.round)
		ctx.setTextDrawingMode(.stroke)
		self.textColor = strokeColor
		super.drawText(in: rect)

		ctx.setTextDrawingMode(.fill)
		self.textColor = strokeColor.withAlphaComponent(0)
		super.drawText(in: rect)
		

		self.textColor = .black
		super.drawText(in: rect)
	}
}
