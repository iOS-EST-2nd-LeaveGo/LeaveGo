//
//  MapHeaderView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import CoreLocation
import UIKit

class MapHeaderViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var displaySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentContentView: UIView!
    
    var placeListVC: PlacesViewController = {
        let vc = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesVC") as! PlacesViewController
        return vc
    }()
    var mapVC: MapViewController = {
        let vc = MapViewController()
        return vc
    }()
    
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
    }
    
    /// loadPlaceList에 필요한 location Data를 얻어옵니다.
    func loadLocation() {
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
    func loadPlaceList() {
        Task {
            if let APIplaceList = try? await NetworkManager.shared.fetchPlaceList(page: 1,
                                                                                  mapX: location.longitude,
                                                                                  mapY: location.latitude,
                                                                                  radius: 2000) {
                _=APIplaceList.map {
                    let place = PlaceModel(contentId: $0.contentId, title: $0.title, thumbnailImage: $0.thumbnailImage, distance: $0.dist, latitude: $0.mapY, longitude: $0.mapX, detail: nil)
                    
                    placeModelList.append(place)
                }
            }
        }
    }
    
    // MARK: Action
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToVC(placeListVC)
        } else {
            switchToVC(mapVC)
        }
    }
    
    func switchToVC(_ newVC: UIViewController) {
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
