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

    private var hasLoadedPlaceList = false
    private var isSearching = false
    private var isFetching = false

	weak var delegate: PlacesViewControllerDelegate?

    private var keyword: String = ""
    private var currentPage = 1
    private var totalCount = 0
    private let numOfRows = 100

    private(set) var currentPlaceModel: [PlaceModel] = []

    var placeModelUpdated: (([PlaceModel]) -> Void)?

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
        guard let currentLocation = currentLocation else {
            return
        }

        guard (currentPage - 1) * numOfRows < totalCount || totalCount == 0 else { return }

        isFetching = true
        Task {
            print("asdf")

            defer { isFetching = false }
            do {
                let (places, count) = try await NetworkManager.shared.fetchPlaceList(
                    page: currentPage,
                    mapX: currentLocation.longitude,
                    mapY: currentLocation.latitude,
                    radius: 2000,
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

                    await loadThumbnailImage()

            } catch {
                print("네트워크 에러: \(error.localizedDescription)")
            }
        }
    }

    private func
    handleFetchedPlaces(places: [PlaceList], count: Int) {
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

            self.placeModelUpdated?(self.currentPlaceModel)

            Task {
                await self.loadThumbnailImage()
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: indexPaths, with: .fade) // 이미지 표시
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

		let place = currentPlaceModel[indexPath.row]
		
		cell.place = place
		cell.delegate = self
		
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

		cell.thumbnailImageView.image = nil
		cell.thumbnailImageView.image = place.thumbnailImage

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
		// Bookmark 화면 이동 코드
		print("tapped bookmark button")
	}
}
