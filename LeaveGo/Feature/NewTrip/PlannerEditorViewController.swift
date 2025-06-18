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

        if let id = plannerID {
            createPlannerBtn.isHidden = true
            print("🄐 전달받은 planner ID: \(id)")

            if let fetchedPlanner = CoreDataManager.shared.fetchOnePlanner(id: id) {
                print("fetchedPlanner: ", fetchedPlanner)

                tripName.text = fetchedPlanner.title

                if let imageName = fetchedPlanner.thumbnailPath {
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
                print("📍 저장된 장소 목록 (\(places))")

    

                self.tripListTableView.reloadData()

            } else {
                print("❌ fetch 실패: planner 참조 실패")
            }
        } else {
            createPlannerBtn.isHidden = false
            print("🌟 새로운 planner 생성 예정")
        }

        if tripThumbnail.image == nil {
            tripThumbnail.image = UIImage(systemName: "photo")
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        }

        tripThumbnail.layer.cornerRadius = 12
        tripThumbnail.clipsToBounds = true

        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self

        tripListTableView.dragInteractionEnabled = true
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self
    }

    @IBAction func thumbnailAddAction(_ sender: UIButton) {
        if isImageSelected {
            tripThumbnail.image = UIImage(systemName: "photo")
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

extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  error == nil else { return }

            DispatchQueue.main.async {
                self.tripThumbnail.image = selectedImage
                self.tripThumbnail.layer.cornerRadius = 12
                self.isImageSelected = true
                self.thumbnailAdd.setTitle("이미지 삭제", for: .normal)
            }
        }
    }
}

extension PlannerEditorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListTableViewCell.self), for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }

        let place = placeList[indexPath.row]
        cell.setupMenu(mode: .draggable)
        cell.checkmarkImageView.image = UIImage(systemName: "line.3.horizontal")
        cell.titleLabel?.text = place.title
        cell.place = place
        cell.thumbnailImageView.image = place.thumbnailImage
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = placeList.remove(at: sourceIndexPath.row)
        placeList.insert(moved, at: destinationIndexPath.row)
    }
}

extension PlannerEditorViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = placeList[indexPath.row]
        let provider = NSItemProvider(object: item.title as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
    }

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
            let alert = UIAlertController(title: "여행 이름을 입력해주세요", message: "여행 제목은 필수 항목입니다.", preferredStyle: .alert)
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
                    print("✅ 써머내일 저장됨: \(fileName)")
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

        for (index, place) in placeList.enumerated() {
            CoreDataManager.shared.createPlannerPlace(
                to: newPlanner,
                date: Date(),
                contentID: place.contentId,
                thumbnailURL: nil,
                order: Int16(index)
            )
        }

        print("✅ 저장 완료: \(newPlanner.title ?? "")")
    }
}
