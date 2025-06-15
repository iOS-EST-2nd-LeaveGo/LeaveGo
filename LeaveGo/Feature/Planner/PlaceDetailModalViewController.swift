//
//  PlaceDetailModalViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import UIKit

class PlaceDetailModalViewController: UIViewController {
    var detailMode = DetailMode.areaBased
    var placeId: Int?
    var placeTitle: String?
    var distance: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    
    @IBOutlet weak var addToBookmark: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let placeId,
              let placeTitle else {
            print("placeId: \(placeId), placetitle: \(placeTitle)")
            return
        }
        
        switch detailMode {
        case .locationBased: break
            
        case .areaBased:
            Task {
                if let place = try await NetworkManager.shared.fetchPlaceDetail(contentId: placeId) {
                    await MainActor.run {
                        titleLabel.text = placeTitle
                        if place.openDate != nil || place.openTime != nil || place.restDate != nil {
                            openTimeLabel.text = "\(place.openDate ?? "") \(place.openTime ?? "") \(place.restDate ?? "")"
                        }
                        
                        if let distance {
                            distanceLabel.text = distance
                        } else {
                            distanceLabel.isHidden = true
                        }
                        
                        contactNumberLabel.text = place.infoCenter
                    }
                }
            }
        }
    }
}
