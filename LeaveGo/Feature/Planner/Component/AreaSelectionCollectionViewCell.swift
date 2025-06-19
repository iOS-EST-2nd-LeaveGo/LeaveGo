//
//  AreaSelectionCollectionViewCell.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/14/25.
//

import UIKit

class AreaSelectionCollectionViewCell: UICollectionViewCell {    
    @IBOutlet weak var areaNameContainer: UIView!
    @IBOutlet weak var areaNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        areaNameContainer.layer.backgroundColor = UIColor.customBackground.cgColor
        areaNameContainer.layer.cornerRadius = 16
        areaNameContainer.clipsToBounds = true
        
        areaNameContainer.isUserInteractionEnabled = false
    }
    
    override var isSelected: Bool {
        didSet {
            areaNameContainer.backgroundColor = isSelected ? .accentLighter : .customBackground
            areaNameContainer.layer.borderColor = isSelected ? UIColor.accent.cgColor : UIColor.customLabel.cgColor
            areaNameContainer.layer.borderWidth = isSelected ? 1 : 0
            areaNameLabel.textColor = isSelected ? .accent : .customLabel
        }
    }
}
