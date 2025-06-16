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
    var place: PlaceModel?

    @IBOutlet weak var checkmarkImaveView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // 셀 모드를 넘겨받아 more 버튼 처리에 대한 분기를 실행
    func setupMenu(mode: CellMode) {
        switch mode {
        case .list:
            // 분기에 맞는 UI 처리
            checkmarkImaveView.isHidden = true
            
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
        default:
            // 분기에 맞는 UI 처리
            moreButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
            distanceLabel.isHidden = true
            timeLabel.isHidden = true
            
            // 장소 기본 정보를 들고 상세 정보 모달 띄우기
            moreButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self,
                      let place
                else { return }
                PlaceActions.presentInfoModal(from: self, place: place)
            }), for: .touchUpInside)
        }
    }
}
