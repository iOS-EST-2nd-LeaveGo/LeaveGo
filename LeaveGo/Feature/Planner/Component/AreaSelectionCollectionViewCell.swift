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
        
        areaNameContainer.layer.borderWidth = 1
        areaNameContainer.layer.borderColor = UIColor.prominentBorder.cgColor
        areaNameContainer.layer.backgroundColor = UIColor.accentLighter.cgColor
        areaNameContainer.layer.cornerRadius = 16
        areaNameContainer.clipsToBounds = true
        
        areaNameContainer.isUserInteractionEnabled = false
    }
    
    override var isSelected: Bool {
        didSet {
            areaNameContainer.backgroundColor = isSelected ? .accent : .accentLighter
            areaNameLabel.textColor = isSelected ? .white : .accent
        }
    }
}
