//
//  PlacesViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import CoreLocation

/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlacesViewController: UIViewController {
    private var currentLocation: CLLocationCoordinate2D?

    private var hasLoadedPlaceList = false
    private var isSearching = false
    private var isFetching = false

    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()

    private var keyword: String = ""
    private var currentPage = 1
    private var totalCount = 0
    private let numOfRows = 100

    private(set) var currentPlaceModel: [PlaceModel] = []

    @IBOutlet weak var tableView: UITableView!

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

        // 위치 업데이트 추적 시작
        LocationManager.shared.startUpdating()
        currentLocation = LocationManager.shared.currentLocation
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

    func configure(with keyword: String) {
        self.keyword = keyword
    }

    func updateKeyword(_ keyword: String) {
        self.keyword = keyword

        isSearching = !keyword.isEmpty

        currentPage = 1
        totalCount = 0

        currentPlaceModel.removeAll()

        tableView.reloadData()

        fetchPlaces()
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
        guard let currentLocation = currentLocation else {
            print("현재 위치 없음11")
            return
        }

        guard (currentPage - 1) * numOfRows < totalCount || totalCount == 0 else { return }

        isFetching = true
		print("@12312321")
        Task {
            defer { isFetching = false }
            do {
                let (places, count) = try await NetworkManager.shared.fetchPlaceList(
                    page: currentPage,
                    mapX: currentLocation.longitude,
                    mapY: currentLocation.latitude,
                    radius: 2000
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

        let place = currentPlaceModel[indexPath.row]

        // 분기 처리를 위해 cell에게 모드 넘겨주고 필요 없는 뷰들 숨기기
        cell.setupMenu(mode: .list)

        cell.titleLabel.text = place.title

        if let distStr = place.distance,
           let distDouble = Double(distStr) {
            cell.distanceLabel.text = "\(Int(round(distDouble)))m 떨어짐"
        } else {
            cell.distanceLabel.text = nil
        }
        cell.timeLabel.text = "09:00 ~ 18:00 • 1시간" // PlaceDetail


        // 이미지 처리
        if let urlStr = place.thumbnailURL,
           let url = URL(string: urlStr) {
            if let cachedImage = imageCache.object(forKey: urlStr as NSString) {
                cell.thumbnailImageView.image = cachedImage
            } else {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let image = UIImage(data: data) else {
                        return
                    }

                    DispatchQueue.main.async {
                        if tableView.indexPath(for: cell) == indexPath {
                            self.imageCache.setObject(image, forKey: urlStr as NSString)
                            cell.thumbnailImageView.image = image
                        }
                    }
                }.resume()
            }
        }

        return cell
    }

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
    }
}
