//
//  AddNewTripViewController.swift
//  LeaveGo
//
//  Created by 김효환 on 6/12/25.
//

import UIKit
import PhotosUI

class PlannerEditorViewController: UIViewController {

    var placeList = [PlaceModel]()
    
    @IBOutlet weak var tripName: UITextField!
    @IBOutlet weak var tripThumbnail: UIImageView!
    @IBOutlet weak var thumbnailAdd: UIButton!
    @IBOutlet weak var tripListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // XIB 등록
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self
    

        // ✅ 드래그 앤 드롭 활성화
        tripListTableView.dragInteractionEnabled = true // 드래그 동작 활성화
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self
        
        // ✅ 임시 데이터
        placeList = [
            PlaceModel(
                contentId: "1001",
                title: "신천역",
                thumbnailURL: nil,
                distance: "1.2km",
                latitude: "37.511",
                longitude: "127.100",
                areaCode: "1",
                cat1: "A", cat2: "B", cat3: "C"
            ),
            PlaceModel(
                contentId: "1002",
                title: "잠실 롯데타워",
                thumbnailURL: nil,
                distance: "2.5km",
                latitude: "37.513",
                longitude: "127.102",
                areaCode: "2",
                cat1: "A", cat2: "C", cat3: "D"
            )
        ]
    }
    
    

    // 썸네일 사진 선택
    @IBAction func thumbnailAddAction(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// PHPicker 결과 처리
extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.last?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  error == nil else { return }

            DispatchQueue.main.async {
                self.tripThumbnail.layer.cornerRadius = 12 // 왜 안될까
                self.tripThumbnail.clipsToBounds = true
                self.tripThumbnail.image = selectedImage
                
            }
        }
    }
}

// 테이블 뷰 관련 설정
extension PlannerEditorViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ListTableViewCell.self),
            for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }

        cell.setupMenu(mode: .draggable)
        cell.distanceLabel?.isHidden = true
        cell.thumbnailImageView.image = UIImage(systemName: "photo.fill")
        
        let place = placeList[indexPath.row]
        cell.checkmarkImaveView.image = UIImage(systemName: "line.3.horizontal") // 드래그 핸들 이미지
        cell.place = place
        cell.titleLabel?.text = place.title

        return cell
    }

    // 드래그 가능한지 여부
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // 실제 배열에서 순서 변경 처리
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = placeList.remove(at: sourceIndexPath.row)
        placeList.insert(moved, at: destinationIndexPath.row)

    }
}

// 드래그 & 드롭 이벤트 처리
extension PlannerEditorViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    // 드래그 시작할 때 호출 (드래그할 항목 지정)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = placeList[indexPath.row]
        let provider = NSItemProvider(object: item.title as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item // 실제 객체를 전달
        return [dragItem]
    }

    // 드롭이 완료될 때 호출 (배열 및 UI 업데이트)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.items.forEach { item in
            // 같은 테이블뷰 내에서 드래그한 경우
            if let sourceIndexPath = item.sourceIndexPath,
               let draggedItem = item.dragItem.localObject as? PlaceModel {
                
                // 데이터 및 UI 동기화
                tableView.performBatchUpdates {
                    placeList.remove(at: sourceIndexPath.row)
                    placeList.insert(draggedItem, at: destinationIndexPath.row)
                    
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                }
            }
        }
    }
}
