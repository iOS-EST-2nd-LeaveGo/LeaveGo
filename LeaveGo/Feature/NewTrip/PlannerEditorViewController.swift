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
    @IBOutlet weak var tripThumbnailContainerView: UIView!
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)

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
            print("하이프 새 planner 생성 예정")
        }

        if tripThumbnail.image == nil {
            isImageSelected = false
            thumbnailAdd.setTitle("이미지 추가", for: .normal)
        }

        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        tripListTableView.register(nib, forCellReuseIdentifier: String(describing: ListTableViewCell.self))
        tripListTableView.dataSource = self
        tripListTableView.delegate = self
        tripListTableView.dragInteractionEnabled = true
        tripListTableView.dragDelegate = self
        tripListTableView.dropDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tripThumbnailContainerView.layer.cornerRadius = 16
        tripThumbnailContainerView.clipsToBounds = true
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

    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ListTableViewCell.self),
            for: indexPath
        ) as? ListTableViewCell else {
            return UITableViewCell()
        }

        let place = placeList[indexPath.row]
        
        cell.setupMenu(mode: .draggable)
        cell.checkmarkImageView.image = UIImage(systemName: "line.3.horizontal")
        cell.titleLabel?.text = place.title
        cell.place = place

        if let image = place.thumbnailImage {
            cell.thumbnailImageView.image = image
        } else if let urlString = place.thumbnailURL, let url = URL(string: urlString) {
            // URL로부터 이미지 다운로드
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = UIImage(data: data), error == nil else { return }

                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = image
                    self.placeList[indexPath.row].thumbnailImage = image
                }
            }.resume()
        } else {
            cell.thumbnailImageView.image = nil
        }

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
                    savedImageName = fileName
                } catch {
                    print("❌ 사진 저장 실패: \(error.localizedDescription)")
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
                title: place.title,
                thumbnailURL: place.thumbnailURL,
                order: Int16(index)
            )
        }

        print("✅ 저장 완료: \(newPlanner.title ?? "")")
    }
}

extension PlannerEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension PlannerEditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
