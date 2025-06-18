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

    @IBAction func navigateToDetailVC(_ sender: Any) {
        print("🤖 Detail VC로 이동하는 코드를 작성해라 휴먼")
        if let id = planner?.id {
               print("🪪 선택된 플래너 ID: \(id)")
           } else {
               print("⚠️ Planner가 설정되지 않음")
           }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        plannerCardStackView.layer.borderWidth = 1
        plannerCardStackView.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
        plannerCardStackView.layer.cornerRadius = 16
        plannerCardStackView.clipsToBounds = true
    }
}
