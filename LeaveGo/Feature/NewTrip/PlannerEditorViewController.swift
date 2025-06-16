//
//  AddNewTripViewController.swift
//  LeaveGo
//
//  Created by 김효환 on 6/12/25.
//

import UIKit
import PhotosUI

class PlannerEditorViewController: UIViewController {
    
    @IBOutlet weak var tripName: UITextField!
    @IBOutlet weak var tripThumbnail: UIImageView!
    @IBOutlet weak var thumbnailAdd: UIButton!
    @IBOutlet weak var tripListTableView: UITableView!
    
    var selectedPlaces: [String] = ["신천역1", "신천역2", "신천역3"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ListTableViewCell XIB 등록
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self
    }
    
    @IBAction func thumbnailAddAction(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1 // 한 장만 선택 가능
        config.filter = .images   // 이미지 타입만
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 이미지 선택 화면 닫기
        
        // 마지막으로 선택된 이미지 가져오기
        guard let provider = results.last?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        // 이미지 로드
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  error == nil else {
                return
            }
            
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                self.tripThumbnail.image = selectedImage
                print("✅ 썸네일 이미지 설정 완료")
                print("이미지 : \(selectedImage)")
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PlannerEditorViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 행 개수 = 장소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPlaces.count
    }

    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ListTableViewCell 재사용
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ListTableViewCell.self),
            for: indexPath) as?
            ListTableViewCell else {
            return UITableViewCell()
        }
        
        // 분기 처리를 위해 cell에게 모드 넘겨주고 필요 없는 뷰들 숨기기
        cell.setupMenu(mode: .selectable)
        cell.distanceLabel?.isHidden = true
        cell.timeLabel?.isHidden = true
        
        // 장소 이름 설정
        let placeName = selectedPlaces[indexPath.row]
        cell.titleLabel?.text = placeName
        
        // 이미지 처리
//        cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
}
