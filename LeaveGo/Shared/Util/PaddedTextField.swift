//
//  PaddedTextField.swift
//  LeaveGo
//
//  Created by 박동언 on 6/11/25.
//

import UIKit

class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
