//
//  MapHeaderView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import CoreLocation
import UIKit

// MARK: - 메인 화면 상단에서 지도와 리스트 전환을 담당하는 컨트롤러
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
        searchBar.delegate = self

        searchBar.backgroundImage = UIImage()
        searchBar.applyBodyTextStyle()

        // 위치 관련 노티 등록
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

        // 세그먼트 컨트롤 액션 연결 및 기본 리스트 화면으로 설정
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    // 해제
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("MapHeaderViewController, 옵저버 해제 완료")
    }

    // MARK: - 위치 응답 처리
    @objc private func locationUpdate(_ notification: Notification) {
        guard let coordinate = notification.object as? CLLocationCoordinate2D else { return }
        currentLocation = coordinate

    }

    @objc private func locationError(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("위치 추적 실패: \(error.localizedDescription)")
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - 세그먼트 변경 시 뷰 전환
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

    // MARK: - 리스트에서 업데이트된 장소 정보를 지도 뷰로 전달
    @objc func placeModelUpdated(_ notification: Notification) {
        if let updatedList = notification.object as? [PlaceModel] {
            self.mapVC.currentPlaceModel = updatedList
        }
    }

    // MARK: - 자식 뷰컨트롤러 전환 처리
    private func switchToVC(_ newVC: UIViewController) {
        // 현재 VC 제거
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }



        // 새 VC 추가
        addChild(newVC)
        newVC.view.frame = segmentContentView.bounds
        segmentContentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
    }
}

// MARK: - 검색바 입력 처리
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
        switchToVC(placeListVC)
        displaySegmentedControl.selectedSegmentIndex = 0
        searchBar.resignFirstResponder()



    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        placeListVC.updateKeyword("")
    }
}

extension UISearchBar {
    func applyBodyTextStyle() {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
}

// MARK: - 장소 셀 선택 시 지도화면으로 이동 및 디테일 시트 표시
extension MapHeaderViewController: PlacesViewControllerDelegate {
    func placesViewController(_ vc: PlacesViewController, didSelect place: PlaceModel) {
        mapVC.selectedPlace = place
        mapVC.currentPlaceModel = vc.currentPlaceModel

        displaySegmentedControl.selectedSegmentIndex = 1
        switchToVC(mapVC)

        mapVC.showDetailSheet(for: place)
    }
}

// MARK: - 탭 제스처가 UIControl에 영향 주지 않도록 설정
extension MapHeaderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
