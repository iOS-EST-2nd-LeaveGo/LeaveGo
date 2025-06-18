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

    lazy var placeListVC: PlacesViewController = {
        let vc = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesVC") as! PlacesViewController
        vc.delegate = self
        return vc
    }()

    lazy var mapVC: MapViewController = {
        let vc = MapViewController()
        return vc
    }()


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var displaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentContentView: UIView!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.backgroundImage = UIImage()
        searchBar.applyBodyTextStyle()

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

        NotificationCenter.default.addObserver(self, selector: #selector(placeModelUpdated(_:)), name: .placeModelUpdated, object: nil)


        // 위치 업데이트 추적 시작
        LocationManager.shared.startUpdating()
        currentLocation = LocationManager.shared.currentLocation
        displaySegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        switchToVC(placeListVC)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false  // 터치 이벤트 전달되게
        view.addGestureRecognizer(tap)
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

    }

    // 위치 추적 실패
    @objc private func locationError(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("위치 추적 실패: \(error.localizedDescription)")
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Action
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToVC(placeListVC)

            if placeListVC.currentPlaceModel.isEmpty {
                placeListVC.fetchPlaces()
            }
        } else {
            switchToVC(mapVC)
            mapVC.currentPlaceModel = placeListVC.currentPlaceModel
            mapVC.isSearching = placeListVC.isSearching
        }
    }

    @objc func placeModelUpdated(_ notification: Notification) {
        if let updatedList = notification.object as? [PlaceModel] {
            self.mapVC.currentPlaceModel = updatedList
        }
    }

    private func switchToVC(_ newVC: UIViewController) {
        // 현재 VC 제거
        if let current = children.first {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // 새 VC 추가
        addChild(newVC)
        newVC.view.frame = segmentContentView.bounds
        segmentContentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
    }
}

extension MapHeaderViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text ?? ""
        placeListVC.updateKeyword(keyword)
        searchBar.resignFirstResponder()

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        placeListVC.updateKeyword("") // 검색 결과 초기화
    }
}

extension UISearchBar {
    func applyBodyTextStyle() {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
}

extension MapHeaderViewController: PlacesViewControllerDelegate {
    func placesViewController(_ vc: PlacesViewController, didSelect place: PlaceModel) {
        mapVC.selectedPlace = place
        mapVC.currentPlaceModel = vc.currentPlaceModel

        displaySegmentedControl.selectedSegmentIndex = 1
        switchToVC(mapVC)

        mapVC.showDetailSheet(for: place)
    }
}
