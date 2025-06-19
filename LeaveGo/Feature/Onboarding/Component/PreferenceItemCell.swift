//
//  PreferenceItemCell.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class PreferenceItemCell: UICollectionViewCell {
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonContainerView.layer.cornerRadius = 16
        buttonContainerView.clipsToBounds = true
        buttonContainerView.layer.backgroundColor = UIColor.customBackground.cgColor
    }

    override var isSelected: Bool {
        didSet {
            buttonContainerView.layer.backgroundColor = isSelected ? UIColor.accent.cgColor : UIColor.customBackground.cgColor
            iconImageView.tintColor = isSelected ? UIColor.white : UIColor.accent
            titleLabel.textColor = isSelected ? UIColor.white : UIColor.accent
        }
    }

    func setup(with item: TransportType) {
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = item.rawValue
    }
}
