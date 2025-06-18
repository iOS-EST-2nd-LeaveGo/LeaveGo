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
    @IBOutlet weak var navigateToPlaceListButton: UIButton!
    @IBOutlet weak var recommendedPlaceCardCollectionView: UICollectionView!
    
    // 추천 장소 더보기 버튼 클릭 시 탭 전환
    @IBAction func navigateToPlaceList(_ sender: UIButton) {
        // 현재 탭바 컨트롤러 접근
        guard let tabBarController = self.tabBarController else { return }

        // Sub.storyboard 로드
        let storyboard = UIStoryboard(name: String(describing: "MapHeader"), bundle: nil)
        
        // SubVC 인스턴스 생성
        guard let mapHeaderVC = storyboard.instantiateViewController(withIdentifier: "MapHeaderNav") as? UINavigationController else {
            print("SubVC를 찾을 수 없습니다")
            return
        }

        // 현재 탭 배열을 가져와 교체하거나 추가
        var viewControllers = tabBarController.viewControllers ?? []
        
        // 원하는 탭 index로 삽입 (예: 1번 탭으로 설정)
        if viewControllers.count > 1 {
            viewControllers[1] = mapHeaderVC
        } else {
            viewControllers.append(mapHeaderVC)
        }

        // 탭 설정 및 이동
        tabBarController.viewControllers = viewControllers
        tabBarController.selectedIndex = 1
    }
    
    var placeList = [PlaceModel]()
    
    private var currentLocation: CLLocationCoordinate2D?
    private var hasLoadedPlaceList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserSetting.shared.nickname {
            welcomMessageLabel.text = "\(userName)님이 좋아하실만한\n주변 관광지들을 골라봤어요."
        } else {
            welcomMessageLabel.text = "내 주변 추천 관광지"
        }
        
        recommendedPlaceCardCollectionView.delegate = self
        recommendedPlaceCardCollectionView.dataSource = self
        navigateToPlaceListButton.layer.borderColor = UIColor.accent.cgColor
        navigateToPlaceListButton.backgroundColor = UIColor.accentLighter
        navigateToPlaceListButton.layer.borderWidth = 1
        navigateToPlaceListButton.layer.cornerRadius = 16

        // 위치 업데이트 추적 시작
        currentLocation = LocationManager.shared.currentLocation

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
                mapX: currentLocation.longitude,
                mapY: currentLocation.latitude,
                radius: 10000,
                contentTypeId: ContentTypeID.touristAttraction.rawValue,
                arrange: "S"
            )
            
            if count > 0 {
                self.placeList = fetchedList.map {
                    PlaceModel(add1: $0.addr1, add2: $0.addr2, contentId: $0.contentId, contentTypeId: $0.contentTypeId, title: $0.title, bigThumbnailURL: $0.bigThumbnailImage, thumbnailURL: $0.thumbnailImage, distance: $0.dist, latitude: $0.mapY, longitude: $0.mapX, areaCode: $0.areaCode, cat1: $0.cat1, cat2: $0.cat2, cat3: $0.cat3)
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
            if let urlString = placeList[index].bigThumbnailURL,
               let url = URL(string: urlString) {
                let image = await fetchThumbnailImage(for: url)
                
                // 이미지 저장은 메인 스레드에서
                DispatchQueue.main.async { [weak self] in
                    self?.placeList[index].bigThumbnailImage = image
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = placeList[indexPath.item]
        
        // PlaceRoute.storyboard에서 뷰컨트롤러 인스턴스 생성
        let sb = UIStoryboard(name: "PlaceRoute", bundle: nil)
        guard let routeVC = sb.instantiateViewController(
            identifier: "PlaceRoute"
        ) as? PlaceRouteViewController else {
            return
        }
        
        routeVC.destination = RouteDestination(place: place)
        
        guard let nav = navigationController else {
            print("navigationController is nil")
            return
        }
        nav.pushViewController(routeVC, animated: true)
    }
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
        
        cell.configure(with: place)
        
        return cell
    }
}
