//
//  PlacesViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import MapKit
/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlacesViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
 
    var placeModelList: [PlaceModel] = [] // NetworkManager로 부터 받아온 PlaceList
    var imageCache: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension PlacesViewController: UITableViewDataSource, ListTableViewCellDelegate {
    /// 테이블 뷰의 셀 개수를 반환합니다.
    /// - Returns: places 배열의 요소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeModelList.count
    }
    
    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        // 분기 처리를 위해 cell에게 모드 넘겨주고 필요 없는 뷰들 숨기기
        cell.setupMenu(mode: .list)
        let place = placeModelList[indexPath.row]
		cell.place = place
		cell.delegate = self
        // 제목
        cell.titleLabel.text = place.title
        
        // 거리 (Int로 변환)
        if let distance = place.distance {
            cell.distanceLabel.text = "\(Int(Double(distance) ?? 0))m 떨어짐"
        }
        // 간단한 시간 정보 (추후 detailIntro2 API로 대체 가능)
        // cell.timeLabel.text = place.detail?.openTime
        
        
        // 이미지 처리        
        cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
    
    // 이 코드는 사용자가 셀을 선택한 후 애니메이션과 함께 선택 효과(회색)를 제거해주는 역할을 합니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
	
	
	/// 경로 찾기 화면 이동
	/// - Parameter cell: 셀 선택이 아닌 버튼 클릭시 경로 찾기 화면 이동 - navigation
	func didTapNavigation(cell: ListTableViewCell) {
		print("▶︎ didTapNavigation called")
		
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		let place = placeModelList[indexPath.row]
		
		// 2) PlaceRoute.storyboard에서 뷰컨트롤러 인스턴스 생성
		let sb = UIStoryboard(name: "PlaceRoute", bundle: nil)
		guard let routeVC = sb.instantiateViewController(
			identifier: "PlaceRoute"
		) as? PlaceRouteViewController else {
			return
		}
		
		print("▶︎ instantiated:", routeVC)
		
		let coord = CLLocationCoordinate2D(latitude: place.latitude,
										   longitude: place.longitude)
		routeVC.destination = RouteDestination(place: place)
		
		// 4) Push
		print("▶︎ navCtrl:", navigationController as Any)
		guard let nav = navigationController else {
			print("navigationController is nil")
			return
		}
		nav.pushViewController(routeVC, animated: true)
//		navigationController?.pushViewController(routeVC, animated: true)
	}

	func didTapBookmark(cell: ListTableViewCell) {
		// Bookmark 화면 이동 코드
		print("tapped bookmark button")
	}

}
