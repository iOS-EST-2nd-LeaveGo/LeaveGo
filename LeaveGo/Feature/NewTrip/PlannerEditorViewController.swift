//
//  AddNewTripViewController.swift
//  LeaveGo
//
//  Created by 김효환 on 6/12/25.
//

import UIKit
import PhotosUI

class PlannerEditorViewController: UIViewController {

    var plannerID: UUID?
    var placeList = [PlaceModel]()
    var isImageSelected = false

    @IBOutlet weak var tripName: PaddedTextField!
    @IBOutlet weak var tripThumbnail: UIImageView!
    @IBOutlet weak var thumbnailAdd: UIButton!
    @IBOutlet weak var tripListTableView: UITableView!
    @IBOutlet weak var createPlannerBtn: UIButton!
    
    @IBAction func addPlannerBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func createPlannerBtn(_ sender: Any) {
        savePlannerData()
        NotificationCenter.default.post(name: .didCreateNewPlanner, object: nil)
        
        if let plannerVC = navigationController?.viewControllers.first(where: { $0 is PlannerViewController }) {
            navigationController?.popToViewController(plannerVC, animated: true)
        
        } else {
            print("⚠️ PlannerViewController가 네비게이션 스택에 없습니다.")
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if plannerID != nil {
            createPlannerBtn.isHidden = true
        } else {
            createPlannerBtn.isHidden = false
        }
        
        if let id = plannerID {
            print("🆔 전달받은 planner ID: \(id)")
            
            if let fetchedPlanner = CoreDataManager.shared.fetchOnePlanner(id: id) {
                tripName.text = fetchedPlanner.title

                // 🔽 썸네일 이미지 로드
                if let imageName = fetchedPlanner.thumbnailPath {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent(imageName)

                    if let image = UIImage(contentsOfFile: fileURL.path) {
                        tripThumbnail.image = image
                        isImageSelected = true
                        thumbnailAdd.setTitle("이미지 삭제", for: .normal)
                    } else {
                        print("❌ 썸네일 로딩 실패 (경로: \(fileURL.path))")
                    }
                }

            } else {
                print("❌ fetch 실패: 해당 ID의 planner를 찾을 수 없음")
            }
        } else {
            print("🆕 새로운 planner 생성 예정 (id 없음)")
            
        }

        // ✅ 썸네일 기본 설정 (없을 경우 대비)
        if tripThumbnail.image == nil {
            tripThumbnail.image = UIImage(systemName: "photo")
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        }

        tripThumbnail.layer.cornerRadius = 12
        tripThumbnail.clipsToBounds = true

        // ✅ 셀 등록 및 테이블 뷰 설정
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self

        tripListTableView.dragInteractionEnabled = true
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self
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
        cell.thumbnailImageView.image = place.thumbnailImage
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
    
    
    func savePlannerData() {
        guard let title = tripName.text, !title.isEmpty else {
            let alert = UIAlertController(
                title: "여행 이름을 입력해주세요",
                message: "여행 제목은 필수 항목입니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        var thumbnailPath: String? = nil
        if let image = tripThumbnail.image, isImageSelected {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(UUID().uuidString).jpg"
                let fileURL = documentsURL.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL)
                    thumbnailPath = fileName
                } catch {
                    print("❌ 이미지 저장 실패: \(error.localizedDescription)")
                }
            }
        }

        let newPlanner = CoreDataManager.shared.createPlanner(
            title: title,
            startDate: startDate,
            endDate: endDate,
            thumbnailPath: thumbnailPath
        )

        print("✅ 저장 완료: \(newPlanner.title ?? "")")
    }

}
