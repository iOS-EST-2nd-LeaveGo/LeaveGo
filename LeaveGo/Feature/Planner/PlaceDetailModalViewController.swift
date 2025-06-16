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
    
    @IBOutlet weak var fetchErrorMessageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var addToBookmark: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        fetchErrorMessageLabel.isHidden = true
        
        guard let place else {
            activityIndicator.stopAnimating()
            return
        }
        
        // PlaceModel 모델을 가지고 placeDetail 을 호출
        Task {
            defer {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
            
            guard let placeDetail = try await NetworkManager.shared.fetchPlaceDetail(contentId: place.contentId) else {
                DispatchQueue.main.async {
                    self.fetchErrorMessageLabel.isHidden = false
                    self.fetchErrorMessageLabel.text = "문제가 발생해 여행지의 상세 정보를 불러오지 못했어요. 😭"
                }
                return
            }
            
            DispatchQueue.main.async {
                self.titleLabel.text = place.title
                
                if placeDetail.restDate == nil && placeDetail.openDate == nil && placeDetail.openTime == nil {
                    self.openTimeLabel.isHidden = true
                } else {
                    self.openTimeLabel.text = "\(placeDetail.restDate ?? " ")\(placeDetail.openDate ?? " ")\(placeDetail.openTime ?? " ")"
                }
                
                if let distance = place.distance {
                    self.distanceLabel.text = Int(distance)?.formatted(.number)
                } else {
                    self.distanceLabel.isHidden = true
                }
                
                if place.add1 == nil && place.add2 == nil {
                    self.addressLabel.isHidden = true
                } else {
                    self.addressLabel.text = "\(place.add1 ?? "") \(place.add2 ?? "")"
                }
                
                if placeDetail.infoCenter == nil {
                    self.contactNumberLabel.isHidden = true
                } else {
                    self.contactNumberLabel.text = placeDetail.infoCenter
                }
            }
        }
    }
}
