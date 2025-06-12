//
//  MapHeaderView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import CoreLocation
import UIKit

final class MapHeaderViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var displaySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentContentView: UIView!
    
    var placeListVC: PlacesViewController = {
        let vc = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesVC") as! PlacesViewController
        return vc
    }()
    var mapVC = MapViewController()
    
    private var currentVC: UIViewController?
    
    var location = CLLocationCoordinate2D()
    var placeModelList: [PlaceModel] = []
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentVC = placeListVC
        
        displaySegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        switchToVC(placeListVC)
        
        loadLocation()
        loadPlaceList()
        loadThumbnailImage()
        
        
    }
    
    /// loadPlaceList에 필요한 location Data를 얻어옵니다.
    private func loadLocation() {
        LocationManager.shared.fetchLocation { [weak self] location, error in
            guard let self = self else { return }
            guard let location = location else {
                print("❌ 위치 가져오기 실패: \(error?.localizedDescription ?? "Location fetch failed.(알 수 없는 error)")")
                return
            }
            
            self.location = location
        }
    }
    
    /// PlaceList들을 load합니다.
    private func loadPlaceList() {
        Task {
            if let APIplaceList = try? await NetworkManager.shared.fetchPlaceList(page: 1,
                                                                                  numOfRows: 20,
                                                                                  mapX: location.longitude,
                                                                                  mapY: location.latitude,
                                                                                  radius: 2000) {
                _=APIplaceList.map {
                    let place = PlaceModel(contentId: $0.contentId, title: $0.title, thumbnailURL: $0.thumbnailImage, distance: $0.dist, latitude: $0.mapY, longitude: $0.mapX, detail: nil)
                    
                    placeModelList.append(place)
                }
                
                self.transportPlaceList()
            }
        }
    }
    
    /// image를 load해서 PlaceModel에 미리 저장해둠
    func loadThumbnailImage() {
        
        _=(0..<placeModelList.count).map { index in
            if let urlString = placeModelList[index].thumbnailURL, let url = URL(string: urlString) {
                
                fetchThumbnailImage(for: url) { [weak self] image in
                    guard let self = self else { return }
                    self.placeModelList[index].thumbnailImage = image
                }
            }
        }
    }
    
    func fetchThumbnailImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data), error == nil {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func transportPlaceList() {
        mapVC.placeModelList = placeModelList
        // TODO: placeListVC에 model 전달
    }
    
    // MARK: Action
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToVC(placeListVC)
        } else {
            switchToVC(mapVC)
        }
    }
    
    private func switchToVC(_ newVC: UIViewController) {
        // 현재 VC 제거
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // 새 VC 추가
        addChild(newVC)
        newVC.view.frame = segmentContentView.bounds
        segmentContentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        currentVC = newVC
    }
    
}
