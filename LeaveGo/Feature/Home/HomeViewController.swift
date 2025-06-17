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
    @IBOutlet weak var recommendedPlaceCardCollectionView: UICollectionView!
    
    var placeList = [PlaceModel]()
    
    private var currentLocation: CLLocationCoordinate2D?
    private var hasLoadedPlaceList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults().string(forKey: "nickname") {
            welcomMessageLabel.text = "\(userName)님이 좋아하실만한\n주변 관광지들을 골라봤어요."
        } else {
            welcomMessageLabel.text = "내 주변 추천 관광지"
        }
        
        recommendedPlaceCardCollectionView.delegate = self
        recommendedPlaceCardCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 300)
        recommendedPlaceCardCollectionView.collectionViewLayout = layout
        
        // LocationManager 작동 방식을 몰라서 현재 위치 강제 지정
        currentLocation = CLLocationCoordinate2D(latitude: 126.76857234333737, longitude: 37.51006358933778)
        
        Task {
            await loadPlaceList()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func loadPlaceList() async {
        guard let currentLocation else {
            print("위치 없음")
            return
        }
        
        do {
            let (fetchedList, count) = try await NetworkManager.shared.fetchPlaceList(
                numOfRows: 5,
                mapX: currentLocation.latitude,
                mapY: currentLocation.longitude,
                radius: 10000,
                contentTypeId: ContentTypeID.touristAttraction.rawValue
            )
            
            if count > 0 {
                self.placeList = fetchedList.map {
                    PlaceModel(add1: $0.addr1, add2: $0.addr2, contentId: $0.contentId, title: $0.title, thumbnailURL: $0.thumbnailImage, distance: $0.dist, latitude: $0.mapY, longitude: $0.mapX, areaCode: $0.areaCode, cat1: $0.cat1, cat2: $0.cat2, cat3: $0.cat3)
                }
                await loadThumbnailImage()
                
                await MainActor.run {
                    self.recommendedPlaceCardCollectionView.reloadData()
                }
            }
        } catch {
            print("장소 리스트 불러오기 실패: ", error)
        }
    }
    
    func loadThumbnailImage() async {
        for index in 0 ..< placeList.count {
            if let urlString = placeList[index].thumbnailURL,
               let url = URL(string: urlString) {
                let image = await fetchThumbnailImage(for: url)
                
                // 이미지 저장은 메인 스레드에서
                DispatchQueue.main.async { [weak self] in
                    self?.placeList[index].thumbnailImage = image
                }
            }
        }
    }
    
    func fetchThumbnailImage(for url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedPlaceCardCollectionViewCell", for: indexPath) as? RecommendedPlaceCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let place = placeList[indexPath.item]
        
        if let thumbnailImage = place.thumbnailImage {
            cell.placeBgImage.image = thumbnailImage
        }
        
        if let distance = place.distance {
            cell.placeDistanceLabel.text = "\(distance.formattedDistance())km 떨어짐"
        }
        
        cell.placeTitleLabel.text = place.title
        
        return cell
    }
}
