//
//  RecommendedPlaceCardCollectionViewCell.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/17/25.
//

import UIKit

class RecommendedPlaceCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var placeBgImage: UIImageView!
    @IBOutlet weak var placeDistanceLabel: UILabel!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeBgImage.layer.cornerRadius = 16
        placeBgImage.clipsToBounds = true
    }
}
