//
//  PlannerAddButtonCollectionViewCell.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import UIKit

class PlannerAddButtonCollectionViewCell: UICollectionViewCell {
    var onTab: (() -> Void)?
    
    @IBOutlet weak var plannerAddButtonView: UIView!
    
    @IBAction func navigateToComposeView(_ sender: UIButton) {
        onTab?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        plannerAddButtonView.layer.borderWidth = 1
        plannerAddButtonView.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
        plannerAddButtonView.layer.cornerRadius = 16
        plannerAddButtonView.clipsToBounds = true
    }

}
