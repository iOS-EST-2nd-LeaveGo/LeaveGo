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
                await loadPlaceList()
            }
        }
    }
    
    private func loadPlaceList() async {
        guard let area else {
            print("지역 선택되지 않음")
            return
        }
        
        do {
            if let fetchedList = try await NetworkManager.shared.FetchAreaBasedPlaceList(area: area) {
                
                self.placeList = fetchedList.map {
                    PlaceModel(contentId: $0.contentId, title: $0.title, thumbnailURL: $0.thumbnailImage, distance: nil, latitude: $0.mapY, longitude: $0.mapX, areaCode: $0.areaCode, cat1: $0.cat1, cat2: $0.cat2, cat3: $0.cat3)
                }
                await loadThumbnailImage() // async로 변경된 버전 호출
                
                // 모든 썸네일까지 다 받은 후 table view 갱신
                DispatchQueue.main.async {
                    self.placeSelectionTable.reloadData()
                }
            }
            
        } catch {
            print("장소 리스트 불러오기 실패:", error.localizedDescription)
        }
    }
    
    // MARK: Load Thumbnail Image
    
    /// image를 load해서 PlaceModel에 미리 저장해둠
    func loadThumbnailImage() async {
        for index in 0 ..< placeList.count {
            if let urlString = placeList[index].thumbnailURL,
               let url = URL(string: urlString) {
                let image = await fetchThumbnailImage(for: url)

                // 이미지 저장은 메인 스레드에서
                DispatchQueue.main.async { [weak self] in
                    self?.placeList[index].thumbnailImage = image
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
        cell.checkmarkImageView.image = UIImage(systemName: "checkmark.circle")
        cell.place = place as PlaceModel
        
        cell.thumbnailImageView.image = place.thumbnailImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedItems.contains(indexPath) {
            selectedItems.append(indexPath)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedItems.firstIndex(of: indexPath) {
            selectedItems.remove(at: index)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
