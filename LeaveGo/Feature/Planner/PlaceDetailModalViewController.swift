//
//  PlaceDetailModalViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import UIKit

class PlaceDetailModalViewController: UIViewController {
    var place: PlaceModel?
    var placeDetail: PlaceDetail?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var addToBookmark: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        guard let place else {
            print("placeId: \(place?.contentId ?? ""), placetitle: \(place?.title ?? "")")
            return
        }
        
        // PlaceModel 모델을 가지고 placeDetail 을 호출
        Task {
            placeDetail = try await NetworkManager.shared.fetchPlaceDetail(contentId: Int(place.contentId)!)
        }
    }
}
