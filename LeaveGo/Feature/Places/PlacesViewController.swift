//
//  PlacesViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import CoreLocation

protocol PlacesViewControllerDelegate: AnyObject {
    func placesViewController(_ vc: PlacesViewController, didSelect place: PlaceModel)
}
/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlacesViewController: UIViewController {
    private var currentLocation: CLLocationCoordinate2D?

    private var lastMapMoveCenter: CLLocationCoordinate2D?
    private var lastMapMoveTime: Date?

    private var hasLoadedPlaceList = false
    private var isFetching = false
    var isSearching = false

    weak var delegate: PlacesViewControllerDelegate?

    private var keyword: String = ""
    private var currentPage = 1
    private var totalCount = 0
    private let numOfRows = 20


    private(set) var currentPlaceModel: [PlaceModel] = []

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mapDidMove(_:)),
            name: .mapDidMove,
            object: nil
        )

        // 위치 업데이트 추적 시작
        //        LocationManager.shared.startUpdating()
        currentLocation = LocationManager.shared.currentLocation

        self.loadingIndicator.startAnimating()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !hasLoadedPlaceList, let current = LocationManager.shared.currentLocation {
            currentLocation = current
            hasLoadedPlaceList = true
            fetchPlaces()
        }
    }

    // 해제
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("PlacesViewController, 옵저버 해제 완료")
    }

    // 위치 변경 될 때
    @objc private func locationUpdate(_ notification: Notification) {
        guard let coordinate = notification.object as? CLLocationCoordinate2D else { return }
        currentLocation = coordinate
        if !hasLoadedPlaceList {
            hasLoadedPlaceList = true
            fetchPlaces()
        }
    }

    // 위치 추적 실패
    @objc private func locationError(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("위치 추적 실패: \(error.localizedDescription)")
        }
    }

    @objc private func mapDidMove(_ notification: Notification) {
        guard !self.isSearching else { return }
        guard let newCenter = notification.object as? CLLocationCoordinate2D else { return }

        let now = Date()

        if let lastCenter = lastMapMoveCenter, let lastTime = lastMapMoveTime {
            let distance = CLLocation(latitude: lastCenter.latitude, longitude: lastCenter.longitude)
                .distance(from: CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude))

            let timeDiff = now.timeIntervalSince(lastTime)

            if distance < 200 && timeDiff < 1 {
                return
            }
        }

        lastMapMoveCenter = newCenter
        lastMapMoveTime = now

        currentPage = 1
        totalCount = 0
        currentPlaceModel.removeAll()
        tableView.reloadData()
        fetchPlaces()
    }

    func configure(with keyword: String) {
        self.keyword = keyword
    }

    func updateKeyword(_ keyword: String) {
        self.keyword = keyword
        isSearching = !self.keyword.isEmpty

        currentPage = 1
        totalCount = 0
        currentPlaceModel.removeAll()
        tableView.reloadData()

        if isSearching {
            fetchPlaces() // 검색어 기반 fetch
        } else {
            hasLoadedPlaceList = false // 위치 기반 fetch를 강제로 다시 하도록
            fetchPlaces()              // 또는 직접 fetchNearbyPlaces() 호출해도 됨
        }
    }

    func fetchPlaces() {
        guard !isFetching else { return }

        if isSearching {
            fetchKeywordPlaces()
        } else {
            fetchNearbyPlaces()
        }
    }

    private func fetchNearbyPlaces() {


        guard let targetLocation = lastMapMoveCenter ?? currentLocation else {
            return
        }

        guard (currentPage - 1) * numOfRows < totalCount || totalCount == 0 else { return }
        isFetching = true

        Task {
            defer { isFetching = false }
            do {
                let (places, count) = try await NetworkManager.shared.fetchPlaceList(
                    page: currentPage,
                    mapX: targetLocation.longitude,
                    mapY: targetLocation.latitude,
                    radius: 10000,
                    contentTypeId: nil
                )
                handleFetchedPlaces(places: places, count: count)
            } catch {
                print("네트워크 에러: \(error.localizedDescription)")
            }
        }
    }

    private func fetchKeywordPlaces() {
        guard (currentPage - 1) * numOfRows < totalCount || totalCount == 0 else { return }

        isFetching = true
        Task {
            defer { isFetching = false }
            do {
                let (places, count) = try await NetworkManager.shared.fetchKeywordPlaceList(
                    page: currentPage,
                    numOfRows: numOfRows,
                    keyword: keyword
                )
                handleFetchedPlaces(places: places, count: count)
            } catch {
                print("네트워크 에러: \(error.localizedDescription)")
            }
        }
    }

    private func handleFetchedPlaces(places: [PlaceList], count: Int) {
        let filtered = places.filter(isAllowedPlace)
        let models = filtered.map { PlaceModel(from: $0) }
        totalCount = count

        DispatchQueue.main.async {

            let startIndex = self.currentPlaceModel.count
            self.currentPlaceModel.append(contentsOf: models)
            let endIndex = self.currentPlaceModel.count

            let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
            self.tableView.insertRows(at: indexPaths, with: .fade)

            self.currentPage += 1


            Task {
                self.loadingIndicator.stopAnimating()

                await self.loadThumbnailImage()

                // 이미지 다 로드한 후 갱신
                await MainActor.run {
                    self.tableView.reloadRows(at: indexPaths, with: .fade)
                    NotificationCenter.default.post(name: .placeModelUpdated, object: self.currentPlaceModel)

                }
            }
        }
    }

    func loadThumbnailImage() async {
        let snapshot = currentPlaceModel

        for (index, model) in snapshot.enumerated() {
            guard let urlString = model.thumbnailURL,
                  let url = URL(string: urlString) else { continue }

            let image = await fetchThumbnailImage(for: url)

            // UI 및 모델 업데이트는 메인 스레드에서 수행
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // 배열이 변경됐을 수 있으니 index 안전 검사
                if index < self.currentPlaceModel.count {
                    self.currentPlaceModel[index].thumbnailImage = image

                    // 셀도 보이는 중이면 바로 반영
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = self.tableView.cellForRow(at: indexPath) as? ListTableViewCell {
                        cell.thumbnailImageView.image = image
                    }
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

    private func isAllowedPlace(_ place: PlaceList) -> Bool {
        guard let intID = Int(place.contentTypeId),
              let typeID = ContentTypeID(rawValue: intID) else {
            return false
        }
        return ContentTypeID.allCases.contains(typeID)
    }
}

extension PlacesViewController: UITableViewDataSource {
    /// 테이블 뷰의 셀 개수를 반환합니다.
    /// - Returns: places 배열의 요소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPlaceModel.count
    }

    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.setCell(model: currentPlaceModel[indexPath.row], mode: .list)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return "'\(keyword)' 검색 결과"
        } else {
            return "현재 위치에서 가까운 순"
        }
    }
}


extension PlacesViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        guard offsetY > contentHeight - height * 1.5 else { return }

        fetchPlaces()
    }

    // 이 코드는 사용자가 셀을 선택한 후 애니메이션과 함께 선택 효과(회색)를 제거해주는 역할을 합니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let place = currentPlaceModel[indexPath.row]
        delegate?.placesViewController(self, didSelect: place)
    }
}

extension PlacesViewController: ListTableViewCellDelegate {
    /// 경로 찾기 화면 이동
    /// - Parameter cell: 셀 선택이 아닌 버튼 클릭시 경로 찾기 화면 이동 - navigation
    /// 경로 찾기 화면 이동
    /// - Parameter cell: 셀 선택이 아닌 버튼 클릭시 경로 찾기 화면 이동 - navigation
    func didTapNavigation(cell: ListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let place = currentPlaceModel[indexPath.row]

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

    func didTapBookmark(cell: ListTableViewCell) {
        if let placeModel = cell.place {
            CoreDataManager.createBookmark(contentID: placeModel.contentId,
                                           title: placeModel.title,
                                           thumbnailImageURL: placeModel.thumbnailURL)
        }

        let alert = UIAlertController(title: "북마크에 저장되었습니다!", message: "마이페이지 > 북마크 장소에서 저장한 여행지를 확인할 수 있어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
        tableView.reloadData()
    }

    func didTapDeleteBookmark(cell: ListTableViewCell) {
        if let placeModel = cell.place {
            let contentId = placeModel.contentId


            if currentPlaceModel.firstIndex(where: { contentId == $0.contentId }) != nil {

                CoreDataManager.shared.deleteBookmark(by: contentId)

                tableView.reloadData()
            }
        }
    }

}
