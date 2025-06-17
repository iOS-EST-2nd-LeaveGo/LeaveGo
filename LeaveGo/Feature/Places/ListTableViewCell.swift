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
    func didTapDeleteBookmark(cell: ListTableViewCell)
}

extension ListTableViewCellDelegate {
    func didTapBookmark(cell: ListTableViewCell) { }
    func didTapDeleteBookmark(cell: ListTableViewCell) { }
}

class ListTableViewCell: UITableViewCell {
    weak var delegate: ListTableViewCellDelegate?
    var place: PlaceModel?

    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var thumbnailImageContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// cell이 재사용 되면서 cell의 모델, 데이터가 유실되는 현상이 있어서 tableView(_ tableView: , trailingSwipeActionsConfigurationForRowAt indexPath: ) -> UISwipeActionsConfiguration? 에서 매번 아래 함수를 호출합니다.
    func setCell(model: PlaceModel, mode: CellMode) {
        self.place = model
        self.titleLabel.text = model.title
        
        if let distance = model.distance {
            self.distanceLabel.text = "\(Int(Double(distance) ?? 0))m 떨어짐"
        } else {
            self.distanceLabel.isHidden = true
        }
        
        self.thumbnailImageView.image = model.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        setupMenu(mode: mode)
    }

    // 셀 모드를 넘겨받아 more 버튼 처리에 대한 분기를 실행
    func setupMenu(mode: CellMode) {
        switch mode {
        case .list(let bookmarked):
            // 분기에 맞는 UI 처리
            checkmarkImageView.isHidden = true
            moreButton.showsMenuAsPrimaryAction = true
            
            if bookmarked { // bookmark 삭제버튼 보여주기
                moreButton.menu = UIMenu(title: "", children: [
                    UIAction(title: "경로 찾기", image: UIImage(systemName: "location")) { [weak self] _ in
                        guard let self else { return }
                        delegate?.didTapNavigation(cell: self)
                    },
                    UIAction(title: "북마크 삭제", image: UIImage(systemName: "bookmark.slash")) { [weak self] _ in
                        guard let self else { return }
                        delegate?.didTapDeleteBookmark(cell: self)
                    }
                ])
            } else { // bookmark 추가 버튼 보여주기
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
            }
            
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
        
        thumbnailImageContainerView.layer.cornerRadius = 8
        thumbnailImageContainerView.clipsToBounds = true
        thumbnailImageContainerView.layer.borderColor = UIColor.border.cgColor
        thumbnailImageContainerView.layer.borderWidth = 1
    }
}
