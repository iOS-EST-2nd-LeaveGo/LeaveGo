//
//  ListTableViewCell.swift
//  LeaveGo
//
//  Created by YC on 6/9/25.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // ✅ 추가: 버튼 클릭 시 ViewController에서 처리할 수 있도록 콜백 선언
    var moreButtonTapped: (() -> Void)?
    
    @IBAction func moreButton(_ sender: Any) {
        moreButtonTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // 다이나믹 타입 글씨에 볼드를 적용하고 싶으면 코드로 해야한다
        let descriptor = titleLabel.font.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        
        // UIFont(size: 0) 은 ListTableViewCell.xib 에서 설정한 폰트를 그대로 적용한다는 의미이다.
        let boldFont = UIFont(descriptor: descriptor, size: 0)
        titleLabel.font = boldFont
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
