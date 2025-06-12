//
//  PreferenceItemCell.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class PreferenceItemCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
    }

    override var isSelected: Bool {
        didSet {
//            contentView.layer.borderWidth = isSelected ? 1 : 0
            contentView.layer.borderColor = UIColor.accent.cgColor
            contentView.layer.backgroundColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }

    func setup(with item: TransportType) {
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = item.rawValue
    }
}
