//
//  PlacesViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlacesViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var places: [PlaceList] = []
    var imageCache: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        Task {
            do {
                let endpoint = Endpoint.placeList(page: 1, numOfRows: 20, mapX: 127.0541534400073, mapY: 37.73755263999631, radius: 1000)
                let request = try NetworkManager.shared.makeRequest(endpoint: endpoint)
                if let result: ResponseRoot<PlaceList> = try await NetworkManager.shared.performRequest(urlRequest: request, type: ResponseRoot<PlaceList>.self) {
                    self.places = result.response.body.items.item
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ 네트워크 요청 실패: \(error)")
            }
        }
        
    }
}

extension PlacesViewController: UITableViewDataSource {
    /// 테이블 뷰의 셀 개수를 반환합니다.
    /// - Returns: places 배열의 요소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        let place = places[indexPath.row]
        // 제목
        cell.titleLabel.text = place.title
        // 거리 (Int로 변환)
        cell.distanceLabel.text = "\(Int(Double(place.dist) ?? 0))m 떨어짐"
        // 간단한 시간 정보 (추후 detailIntro2 API로 대체 가능)
        cell.timeLabel.text = "09:00 ~ 18:00 • 1시간"
        
        
        // 이미지 처리
        // 1. PlaceList의 thumbnailImage는 String? 타입이므로 nil인지 확인
        // 2. nil이 아니고 빈 문자열이 아닌 경우, URL 생성 시도
        if let thumbnail = place.thumbnailImage,
           !thumbnail.isEmpty,
           let imageUrl = URL(string: thumbnail) {
            
            // 3. 이미지 캐시에 저장된 이미지가 있다면 바로 사용
            if let cachedImage = imageCache[thumbnail] {
                cell.thumbnailImageView.image = cachedImage
            } else {
                // 4. 백그라운드에서 이미지 다운로드
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageUrl),
                       let image = UIImage(data: data) {
                        
                        // 5. 다운로드 성공 시 캐시에 저장 후 UI 업데이트
                        DispatchQueue.main.async {
                            self.imageCache[thumbnail] = image
                            if self.tableView.indexPath(for: cell) == indexPath {
                                cell.thumbnailImageView.image = image
                            }
                        }
                    } else {
                        // 6. 다운로드 실패 시 기본 아이콘 표시
                        DispatchQueue.main.async {
                            cell.thumbnailImageView.image = UIImage(systemName: "pencil.circle.fill")
                        }
                    }
                }
            }
        } else {
            // 7. 이미지가 없거나 URL이 잘못된 경우 기본 아이콘 표시
            cell.thumbnailImageView.image = UIImage(systemName: "pencil.circle.fill")
        }
        
        return cell
    }
    
    // 이 코드는 사용자가 셀을 선택한 후 애니메이션과 함께 선택 효과(회색)를 제거해주는 역할을 합니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
