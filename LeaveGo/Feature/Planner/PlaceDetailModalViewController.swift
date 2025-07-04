//
//  PlaceDetailModalViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/16/25.
//

import UIKit

protocol PlaceDetailModalDelegate: AnyObject {
	func placeDetailModalDidTapFindRouteButton(_ controller: PlaceDetailModalViewController,
											   didSelectRoute destination: RouteDestination)
}

class PlaceDetailModalViewController: UIViewController {
    var place: PlaceModel?
    var placeDetail: PlaceDetailProtocol?
	weak var delegate: (PlaceDetailModalDelegate)?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var workingHourStackView: UIStackView!
    @IBOutlet weak var restDateLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findRouteButton: UIButton!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    @IBOutlet weak var addToBookmark: UIButton!
    
    /// 북마크 선택 상태에 따라 북마크 star ui 변경
    var didSelectBookmark: Bool = false {
        didSet {
            if didSelectBookmark {
                bookmarkButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                bookmarkButton.tintColor = .accent
            } else {
                bookmarkButton.setImage(UIImage(systemName: "star"), for: .normal)
                bookmarkButton.tintColor = .label
            }
        }
    }
    
    // 상세 정보를 fetch 하지 못했을 때 보여줄 Placeholder 텍스트
    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "문제가 발생해\n여행지의 상세 정보를 불러오지 못했어요."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true // 초기에는 숨김
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

	/// 경로 찾기 버튼 액션 - 경로 탐색 뷰로 이동
	/// - Parameter sender: UIButton 클릭시 목적지 데이터를 담아 showRouteScreen에 전달
	@IBAction func findRouteTapped(_ sender: UIButton) {
		guard let place = place else { return }
		let dest = RouteDestination(place: place)

		if UIDevice.current.userInterfaceIdiom == .pad {
			// iPad: presentingViewController 검사 없이 바로 delegate
			delegate?.placeDetailModalDidTapFindRouteButton(self,
															didSelectRoute: dest)
		} else {
			guard presentingViewController != nil else {
				print("⚠️presentingViewController가 없습니다")
				return
			}
			
			dismiss(animated: true) {
				self.delegate?
					.placeDetailModalDidTapFindRouteButton(
						self,
						didSelectRoute: dest
					)
			}
		}
	}
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurEffectView.applyFeatherMask(to: blurEffectView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.titleLabel.isHidden = true
        self.bookmarkButton.isHidden = true
        self.workingHourStackView.isHidden = true
        self.restDateLabel.isHidden = true
        self.openTimeLabel.isHidden = true
        self.distanceLabel.isHidden = true
        self.addressLabel.isHidden = true
        self.contactNumberLabel.isHidden = true
        self.findRouteButton.isHidden = true
        
        
        guard let place else {
            activityIndicator.stopAnimating()
            return
        }


        view.addSubview(errorMessageLabel)
        
        NSLayoutConstraint.activate([
            errorMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // PlaceModel 모델을 가지고 placeDetail 을 호출
        Task {
            defer {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
            
            guard let placeDetail = try await NetworkManager.shared.fetchPlaceDetail(contentTypeId: place.contentTypeId, contentId: place.contentId) else {
                await MainActor.run {
                    self.errorMessageLabel.isHidden = false
                }
                return
            }

            self.placeDetail = placeDetail

            await MainActor.run {
                self.errorMessageLabel.isHidden = true
                self.titleLabel.isHidden = false
                self.bookmarkButton.isHidden = false
                self.workingHourStackView.isHidden = false
                self.restDateLabel.isHidden = false
                self.openTimeLabel.isHidden = false
                self.distanceLabel.isHidden = false
                self.addressLabel.isHidden = false
                self.contactNumberLabel.isHidden = false
                self.findRouteButton.isHidden = false
                
                self.titleLabel.text = place.title
                
                if self.placeDetail?.restDate == nil && self.placeDetail?.openTime == nil {
                    self.workingHourStackView.isHidden = true
                } else {
                    if let restDate = self.placeDetail?.restDate,
                       let openTime = self.placeDetail?.openTime
                    {
                        if restDate == "" {
                            self.restDateLabel.isHidden = true
                        } else {
                            if restDate.contains("무휴") {
                                self.restDateLabel.text = restDate
                            } else {
                                self.restDateLabel.text = "\(restDate) 휴무"
                            }
                        }
                        
                        if openTime == "" {
                            self.openTimeLabel.isHidden = true
                        } else {
                            self.openTimeLabel.text = self.placeDetail?.openTime
                        }
                    }
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
                
                if self.placeDetail?.infoCenter == nil {
                    self.contactNumberLabel.isHidden = true
                } else {
                    self.contactNumberLabel.text = self.placeDetail?.infoCenter
                }
            }
        }
        
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
