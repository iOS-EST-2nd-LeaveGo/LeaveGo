//
//  PlaceSelectionTableViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/14/25.
//

import UIKit

/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlaceSelectionTableViewController: UIViewController {
    @IBOutlet weak var placeSelectionTable: UITableView!

    var area: Area?
    var placeList = [AreaBasedPlaceList]()
    var imageCache: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        placeSelectionTable.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        placeSelectionTable.dataSource = self
        placeSelectionTable.delegate = self
        
        Task {
            if area != nil {
                placeList = try await NetworkManager.shared.FetchAreaBasedPlaceList(area: area!)!
                placeSelectionTable.reloadData()
            }
        }
    }
}


extension PlaceSelectionTableViewController: UITableViewDataSource {
    /// 테이블 뷰의 셀 개수를 반환합니다.
    /// - Returns: places 배열의 요소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }
    
    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListTableViewCell.self), for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        let place = placeList[indexPath.row]
        // 제목
        cell.titleLabel.text = place.title
        // 간단한 시간 정보 (추후 detailIntro2 API로 대체 가능)
        cell.timeLabel.text = "09:00 ~ 18:00 • 1시간" // PlaceDetail
        
        
        // 이미지 처리
//        cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
    
    // 이 코드는 사용자가 셀을 선택한 후 애니메이션과 함께 선택 효과(회색)를 제거해주는 역할을 합니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PlaceSelectionTableViewController: UITableViewDelegate {
    
}
