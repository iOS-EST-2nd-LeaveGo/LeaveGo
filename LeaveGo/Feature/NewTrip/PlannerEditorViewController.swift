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
    var savedImageName: String?

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

        // 상세페이지 일때 (id 값을 가지고 페이지에 들어올때)
        if let id = plannerID {
            createPlannerBtn.isHidden = true

            if let fetchedPlanner = CoreDataManager.shared.fetchOnePlanner(id: id) {
                tripName.text = fetchedPlanner.title

                if let imageName = fetchedPlanner.thumbnailPath {
                    savedImageName = imageName
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent(imageName)

                    if let image = UIImage(contentsOfFile: fileURL.path) {
                        tripThumbnail.image = image
                        isImageSelected = true
                        thumbnailAdd.setTitle("이미지 삭제", for: .normal)
                    } else {
                        print("❌ 사진 로드 실패: \(fileURL.path)")
                    }
                }

                let places = CoreDataManager.shared.fetchPlannerPlaces(for: fetchedPlanner)

                self.placeList = places.map { entity in
                    print("🆔 contentID: \(entity.contentID ?? "nil")")
                    return PlaceModel(
                        add1: nil,
                        add2: nil,
                        contentId: entity.contentID ?? "unknown-id",
                        contentTypeId: "12",
                        title: entity.title ?? "제목 없음",
                        bigThumbnailURL: nil,
                        thumbnailURL: entity.thumbnailURL,
                        distance: nil,
                        latitude: "0.0",
                        longitude: "0.0",
                        areaCode: nil,
                        cat1: nil,
                        cat2: nil,
                        cat3: nil
                    )
                }
                self.tripListTableView.reloadData()

            } else {
                print("❌ fetch 실패: planner 참조 실패")
            }
        } else {
            createPlannerBtn.isHidden = false
        }

        if tripThumbnail.image == nil {
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        }

        tripThumbnail.layer.cornerRadius = 12
        tripThumbnail.clipsToBounds = true

        // 📄 여행지 목록 셀 등록 및 테이블뷰 설정
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))

        // 📊 테이블뷰 데이터 구성 및 이벤트 처리
        tripListTableView.dataSource = self
        tripListTableView.delegate = self

        // ✋ 드래그 & 드롭 기능 활성화
        tripListTableView.dragInteractionEnabled = true
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self

    }

    @IBAction func thumbnailAddAction(_ sender: UIButton) {
        if isImageSelected {
            if let imageName = savedImageName {
                let fileManager = FileManager.default
                if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsURL.appendingPathComponent(imageName)
                    if fileManager.fileExists(atPath: fileURL.path) {
                        do {
                            try fileManager.removeItem(at: fileURL)
                            print("🗑️ 이미지 삭제됨: \(fileURL.lastPathComponent)")
                        } catch {
                            print("❌ 삭제 실패: \(error.localizedDescription)")
                        }
                    }
                }
            }

            tripThumbnail.image = nil
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        } else {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        }
    }
}

// 📷 PHPickerViewController 이미지 선택 처리
extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    /// 사용자가 이미지 선택을 완료했을 때 호출됨
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 피커 닫기

        // 첫 번째 결과에서 UIImage 타입의 객체 로드 가능한지 확인
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // UIImage 객체 비동기 로드
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  error == nil else { return }

            // 메인 쓰레드에서 UI 업데이트
            DispatchQueue.main.async {
                self.tripThumbnail.image = selectedImage
                self.tripThumbnail.layer.cornerRadius = 12
                self.isImageSelected = true
                self.thumbnailAdd.setTitle("이미지 삭제", for: .normal)
            }
        }
    }
}


// 📋 여행지 목록을 보여주는 테이블 뷰 구성 및 드래그 순서 변경 처리
extension PlannerEditorViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// 섹션 내 셀 개수 반환 (여행지 개수)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }

    /// 각 셀에 데이터 바인딩 및 UI 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 재사용 가능한 셀 가져오기
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ListTableViewCell.self),
            for: indexPath
        ) as? ListTableViewCell else {
            return UITableViewCell()
        }

        // 해당 위치의 장소 정보 가져오기
        let place = placeList[indexPath.row]
        
        // 셀 설정: 드래그 메뉴, 타이틀, 체크 아이콘
        cell.setupMenu(mode: .draggable)
        cell.checkmarkImageView.image = UIImage(systemName: "line.3.horizontal") // 드래그용 아이콘
        cell.titleLabel?.text = place.title
        cell.place = place

        // 썸네일 이미지 설정
        if let image = place.thumbnailImage {
            // 메모리에 캐싱된 이미지가 있을 경우 바로 적용
            cell.thumbnailImageView.image = image
        } else if let urlString = place.thumbnailURL, let url = URL(string: urlString) {
            // URL을 통해 이미지 비동기 다운로드
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = UIImage(data: data), error == nil else { return }

                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = image                       // 셀 이미지 업데이트
                    self.placeList[indexPath.row].thumbnailImage = image       // 메모리에 캐싱
                }
            }.resume()
        } else {
            // 이미지가 없을 경우 비움
            cell.thumbnailImageView.image = nil
        }

        return cell
    }

    /// 해당 셀이 이동 가능한지 여부 (모든 셀 true 반환)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /// 셀 이동 시 placeList 배열 순서도 함께 변경
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = placeList.remove(at: sourceIndexPath.row)
        placeList.insert(moved, at: destinationIndexPath.row)
    }
}

// 🧲 테이블뷰 드래그 & 드롭 구현 + 플래너 저장 처리
extension PlannerEditorViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    /// ✋ 사용자가 셀을 드래그 시작할 때 호출됨
    /// 드래그할 데이터를 UIDragItem으로 생성
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = placeList[indexPath.row]
        let provider = NSItemProvider(object: item.title as NSString)  // 드래그 시 제공할 데이터
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item  // 실제 객체를 로컬에 보존 (이동 시 활용)
        return [dragItem]
    }

    /// 📥 드롭 수행 시 호출됨 — 내부 데이터(placeList)와 테이블 뷰를 함께 업데이트
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        coordinator.items.forEach { item in
            if let sourceIndexPath = item.sourceIndexPath,
               let draggedItem = item.dragItem.localObject as? PlaceModel {
                // 데이터 및 테이블뷰 업데이트
                tableView.performBatchUpdates {
                    placeList.remove(at: sourceIndexPath.row)
                    placeList.insert(draggedItem, at: destinationIndexPath.row)

                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                }
            }
        }
    }

    /// 💾 플래너 및 장소 목록을 Core Data에 저장
    func savePlannerData() {
        // 제목이 비어있는 경우 사용자에게 알림 표시
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

        // 이미지가 선택되었으면 파일로 저장 후 경로 저장
        if let image = tripThumbnail.image, isImageSelected {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(UUID().uuidString).jpg"
                let fileURL = documentsURL.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL)
                    thumbnailPath = fileName                     // 파일 이름만 저장
                    savedImageName = fileName                   // 나중에 삭제 등을 위해 보존
                } catch {
                    print("❌ 사진 저장 실패: \(error.localizedDescription)")
                }
            }
        }

        // Core Data에 새 플래너 저장
        let newPlanner = CoreDataManager.shared.createPlanner(
            title: title,
            startDate: startDate,
            endDate: endDate,
            thumbnailPath: thumbnailPath
        )

        // 장소 목록도 순서대로 저장
        for (index, place) in placeList.enumerated() {
            CoreDataManager.shared.createPlannerPlace(
                to: newPlanner,
                date: Date(),
                contentID: place.contentId,
                title: place.title,
                thumbnailURL: place.thumbnailURL,
                order: Int16(index)
            )
        }

        print("✅ 저장 완료: \(newPlanner.title ?? "")")
    }
}
