//
//  RecommendedPlaceCardCollectionViewCell.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/17/25.
//

import UIKit

class RecommendedPlaceCardCollectionViewCell: UICollectionViewCell {
    var place: PlaceModel?
    
    @IBOutlet weak var placeBgImage: UIImageView!
    @IBOutlet weak var placeDistanceLabel: UILabel!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var didSelectBookmark: Bool = false {
        didSet {
            if didSelectBookmark {
                bookmarkButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                bookmarkButton.tintColor = .accent
            } else {
                bookmarkButton.setImage(UIImage(systemName: "star"), for: .normal)
                bookmarkButton.tintColor = .white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeBgImage.layer.cornerRadius = 16
        placeBgImage.clipsToBounds = true
        placeBgImage.addGradientOverlay(to: self.placeBgImage)
    }
    
    func configure(with place: PlaceModel) {
        self.place = place
       
        if let thumbnailImage = place.bigThumbnailImage {
            self.placeBgImage.image = thumbnailImage
        }
        
        if let distance = place.distance {
            self.placeDistanceLabel.text = "\(distance.formattedDistance())m 떨어짐"
        }
        
        self.placeTitleLabel.text = place.title
        
        didSelectBookmark = CoreDataManager.shared.isBookmarked(contentID: place.contentId)
    }
    
    @IBAction func addBookmark(_ sender: Any) {
        guard let place = place else { return }
        
        if didSelectBookmark { // 북마크 선택된 상태 (coreData에 값이 있는 상태)
            CoreDataManager.shared.deleteBookmark(by: place.contentId)
            didSelectBookmark = CoreDataManager.shared.isBookmarked(contentID: place.contentId)
        } else { // 북마크 선택안된 상태
            CoreDataManager.createBookmark(contentID: place.contentId, title: place.title, thumbnailImageURL: place.thumbnailURL)
            didSelectBookmark = CoreDataManager.shared.isBookmarked(contentID: place.contentId)
        }
    }
    
}
