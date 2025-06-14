//
//  ListTableViewCell.swift
//  LeaveGo
//
//  Created by YC on 6/9/25.
//

import UIKit

protocol ListTableViewCellDelegate: AnyObject {
    func didTapNavigation(cell: ListTableViewCell)
    func didTapBookmark(cell: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    weak var delegate: ListTableViewCellDelegate?

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMenu()
    }

    func setupMenu() {
        moreButton.menu = UIMenu(title: "", children: [
            UIAction(title: "경로 찾기", image: UIImage(systemName: "location")) { [weak self] _ in
                guard let self else { return }
                delegate?.didTapNavigation(cell: self)
            },
            UIAction(title: "북마크 저장", image: UIImage(systemName: "bookmark")) { [weak self] _ in
                guard let self else { return }
                delegate?.didTapBookmark(cell: self)
            }
        ])
        moreButton.showsMenuAsPrimaryAction = true
    }
}
