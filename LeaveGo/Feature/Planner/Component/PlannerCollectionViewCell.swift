//
//  PlannerCollectionViewCell.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import UIKit

class PlannerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plannerCardStackView: UIStackView!
    @IBOutlet weak var plannerThumbnailImageView: UIImageView!
    @IBOutlet weak var plannerTitleLabelView: UILabel!
    
    var planner: Planner?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        plannerCardStackView.layer.borderWidth = 1
        plannerCardStackView.layer.borderColor = UIColor.prominentBorder.cgColor
        plannerCardStackView.layer.cornerRadius = 16
        plannerCardStackView.clipsToBounds = true
    }
}
