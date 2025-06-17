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
    var isImageSelected = false

    @IBOutlet weak var tripName: PaddedTextField!
    @IBOutlet weak var tripThumbnail: UIImageView!
    @IBOutlet weak var thumbnailAdd: UIButton!
    @IBOutlet weak var tripListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tripThumbnail.image = UIImage(systemName: "photo")
        tripThumbnail.layer.cornerRadius = 12
        tripThumbnail.clipsToBounds = true
        isImageSelected = false
        thumbnailAdd.setTitle("이미지 추가", for: .normal)

        // ListTableViewCell XIB 등록
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self

        tripListTableView.dragInteractionEnabled = true
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self

        // ✅ 임시 데이터 추가
        placeList = [PlaceModel(
                add1: "서울특별시 송파구",
                add2: "신천동",
                contentId: "1001",
                title: "신천역",
                thumbnailURL: nil,
                distance: "1.2km",
                latitude: "37.511",
                longitude: "127.100",
                areaCode: "1",
                cat1: "A", cat2: "B", cat3: "C"
            )]
    }

    // 썸네일 사진 선택 / 삭제 버튼 토글
    @IBAction func thumbnailAddAction(_ sender: UIButton) {
        if isImageSelected {
            // 이미지 삭제
            tripThumbnail.image = UIImage(systemName: "photo")
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        } else {
            // 이미지 추가 동작
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        }
    }
}

// PHPicker 결과 처리
extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  error == nil else { return }

            DispatchQueue.main.async {
                self.tripThumbnail.image = selectedImage
                self.tripThumbnail.layer.cornerRadius = 12 // 얘 말 안들음
                self.isImageSelected = true
                self.thumbnailAdd.setTitle("이미지 삭제", for: .normal)
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

        // 셀 설정
        let place = placeList[indexPath.row] // 현재 인덱스에 해당하는 장소(place) 데이터를 가져옴
        cell.setupMenu(mode: .draggable)
        cell.checkmarkImageView.image = UIImage(systemName: "line.3.horizontal")
        cell.titleLabel?.text = place.title
        cell.place = place // 셀 내부에서 사용할 place 데이터를 바인딩
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
        dragItem.localObject = item
        return [dragItem]
    }

    // 드롭이 완료될 때 호출 (배열 및 UI 업데이트)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        coordinator.items.forEach { item in
            if let sourceIndexPath = item.sourceIndexPath,
               let draggedItem = item.dragItem.localObject as? PlaceModel {
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
