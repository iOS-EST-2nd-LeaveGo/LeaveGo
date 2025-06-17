//
//  HomeViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet weak var welcomMessageLabel: UILabel!
    @IBOutlet weak var placeCollectionView: UICollectionView!
//    @IBOutlet weak var placeBgImage: UIImageView!
//    @IBOutlet weak var placeDistanceLabel: UILabel!
//    @IBOutlet weak var bookmarkButton: UIButton!
    
    var placeList: [PlaceList]?
    
    private var currentLocation: CLLocationCoordinate2D?
    private var hasLoadedPlaceList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults().string(forKey: "nickname") {
            welcomMessageLabel.text = "\(userName)님이 좋아하실만한\n주변 관광지들을 골라봤어요."
        } else {
            welcomMessageLabel.text = "내 주변 추천 관광지"
        }
        
        placeCollectionView.delegate = self
        placeCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // LocationManager 작동 방식을 몰라서 현재 위치 강제 지정
        currentLocation = CLLocationCoordinate2D(latitude: 126.76857234333737, longitude: 37.51006358933778)
        
        loadPlaceList()
    }
    
    private func loadPlaceList() {
        Task {
            guard let currentLocation else {
                print("위치 없음")
                return
            }
            
            let (placeList, count) = try await NetworkManager.shared.fetchPlaceList(
                numOfRows: 5,
                mapX: currentLocation.latitude,
                mapY: currentLocation.longitude,
                radius: 10000,
                contentTypeId: ContentTypeID.touristAttraction.rawValue
            )
            
            await MainActor.run {
                updateCollectionView()
            }
        }
    }
    
    private func updateCollectionView() {
        
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedPlaceCardCell", for: indexPath)
        return cell
    }
    
    
}
