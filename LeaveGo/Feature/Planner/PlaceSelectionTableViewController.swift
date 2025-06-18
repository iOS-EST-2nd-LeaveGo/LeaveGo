//
//  PlaceSelectionTableViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/14/25.
//

import UIKit

class PlaceSelectionTableViewController: UIViewController {
    @IBOutlet weak var placeSelectionTable: UITableView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var addToPlannerButton: UIButton!
    
    @IBAction func navigateToComposeVC(_ sender: UIButton) {
        // 스토리보드 불러오기
        let plannerEditorStoryboard = UIStoryboard(name: "PlannerEditor", bundle: nil)

        // ID를 통해 ViewController 인스턴스화
        if let composeVC = plannerEditorStoryboard.instantiateViewController(withIdentifier: "PlannerEditorVC") as? PlannerEditorViewController {
            if selectedPlaceList.count > 0 {
                self.navigationController?.pushViewController(composeVC, animated: true)
                composeVC.placeList = selectedPlaceList
            }
        }
    }
    
    var area: Area?
    var placeList = [PlaceModel]()
    var selectedItems: [IndexPath] = []
    var selectedPlaceList = [PlaceModel]()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurEffectView.applyFeatherMask(to: blurEffectView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        placeSelectionTable.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        placeSelectionTable.dataSource = self
        placeSelectionTable.delegate = self
        placeSelectionTable.allowsMultipleSelection = true
        placeSelectionTable.setEditing(false, animated: true)
        placeSelectionTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        
        addToPlannerButton.isEnabled = false
        
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
                    PlaceModel(add1: $0.addr1, add2: $0.addr2, contentId: $0.contentId, title: $0.title, thumbnailURL: $0.thumbnailImage, distance: nil, latitude: $0.mapY, longitude: $0.mapX, areaCode: $0.areaCode, cat1: $0.cat1, cat2: $0.cat2, cat3: $0.cat3)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }
}

extension PlaceSelectionTableViewController: UITableViewDelegate {
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
            
            let selectedPlace = placeList[indexPath.row]
            selectedPlaceList.append(selectedPlace)
            
            if addToPlannerButton.isEnabled == false {
                addToPlannerButton.isEnabled.toggle()
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = selectedItems.firstIndex(of: indexPath) {
            selectedItems.remove(at: index)
            
            selectedPlaceList.remove(at: index)
            
            print(selectedItems.count)
            addToPlannerButton.isEnabled = selectedItems.count > 0
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
