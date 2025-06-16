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
    private var currentLocation: CLLocationCoordinate2D?
    private var hasLoadedPlaceList = false

    private var currentVC: UIViewController?

    var placeListVC: PlacesViewController = {
        let vc = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesVC") as! PlacesViewController
        return vc
    }()
    var mapVC = MapViewController()

    var placeModelList: [PlaceModel] = []

    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var displaySegmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentContentView: UIView!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationUpdate(_:)),
            name: .locationDidUpdate,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationError(_:)),
            name: .locationUpdateDidFail,
            object: nil
        )

        // 위치 업데이트 추적 시작
       	LocationManager.shared.startUpdating()

        currentVC = placeListVC

        displaySegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        switchToVC(placeListVC)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPlaceList()
    }

    // 해제
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("MapHeaderViewController, 옵저버 해제 완료")
    }

    // 위치 변경 될 때
    @objc private func locationUpdate(_ notification: Notification) {
        guard let coordinate = notification.object as? CLLocationCoordinate2D else { return }
        currentLocation = coordinate

        if !hasLoadedPlaceList {
            hasLoadedPlaceList = true
            loadPlaceList()
        }
    }

    // 위치 추적 실패
    @objc private func locationError(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("위치 추적 실패: \(error.localizedDescription)")
        }
    }

    /// PlaceList들을 load합니다.
    private func loadPlaceList() {
        Task {
            guard let currentLocation else {
                print("위치 없음")
                return
            }

            if let APIplaceList = try? await NetworkManager.shared.fetchPlaceList(page: 1,
                                                                                  numOfRows: 20,
                                                                                  mapX: currentLocation.longitude,
                                                                                  mapY: currentLocation.latitude,
                                                                                  radius: 2000) {
                _ = APIplaceList.map {
                    let place = PlaceModel(contentId: $0.contentId, title: $0.title, thumbnailURL: $0.thumbnailImage, distance: $0.dist, latitude: $0.mapY, longitude: $0.mapX/*, detail: nil*/)
                    placeModelList.append(place)
                }

                /// PlaceList API Load 후 ThumbnailImage Load
                self.loadThumbnailImage()
            }
        }
    }

    /// image를 load해서 PlaceModel에 미리 저장해둠
    func loadThumbnailImage() {

        _ = (0..<placeModelList.count).map { index in
            if let urlString = placeModelList[index].thumbnailURL, let url = URL(string: urlString) {

                fetchThumbnailImage(for: url) { [weak self] image in
                    guard let self = self else { return }

                    /// image까지 완전히 load된 이후 완전체 Model을 VC들에게 전달합니다.
                    /// placeListVC의 tableView를 다시 그려줍니다.
                    self.placeModelList[index].thumbnailImage = image
                    self.transportPlaceList()
                    placeListVC.tableView.reloadData()
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
                DispatchQueue.main.async {
                    completion(nil)
                }
                print(error ?? "image fetch error")
            }
        }.resume()
    }

    /// placeModelList를 각 VC에 전달
    private func transportPlaceList() {
        placeListVC.placeModelList = placeModelList
        mapVC.placeModelList = placeModelList
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
