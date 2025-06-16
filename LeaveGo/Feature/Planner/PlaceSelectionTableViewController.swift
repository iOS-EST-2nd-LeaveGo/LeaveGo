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
    var placeList = [PlaceModel]()
    var imageCache: [String: UIImage] = [:]
    var selectedItems: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        placeSelectionTable.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        placeSelectionTable.dataSource = self
        placeSelectionTable.delegate = self
        placeSelectionTable.allowsMultipleSelection = true
        placeSelectionTable.setEditing(false, animated: true)
        
        Task {
            if area != nil {
                // TODO: PlaceModel 분기처리해서 맞는 모델로 디코딩하기
                // placeList = try await NetworkManager.shared.FetchAreaBasedPlaceList(area: area!)!
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
}

extension PlaceSelectionTableViewController: UITableViewDelegate {
    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListTableViewCell.self), for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        // 분기 처리를 위해 cell에게 모드 넘겨주고 필요 없는 뷰들 숨기기
        cell.setupMenu(mode: .selectable)
        tableView.allowsMultipleSelection = true
        cell.selectionStyle = .none
        
        let place = placeList[indexPath.row]
        cell.titleLabel.text = place.title
        cell.checkmarkImaveView.image = UIImage(systemName: "checkmark.circle")
        cell.place = place as PlaceModel
        
        // 이미지 처리
        // cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedItems.contains(indexPath) {
            selectedItems.append(indexPath)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.checkmarkImaveView.image = UIImage(systemName: "checkmark.circle.fill")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedItems.firstIndex(of: indexPath) {
            selectedItems.remove(at: index)
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
