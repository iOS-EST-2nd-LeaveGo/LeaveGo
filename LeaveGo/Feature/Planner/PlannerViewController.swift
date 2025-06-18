//
//  PlannerViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

class PlannerViewController: UIViewController {
    @IBOutlet weak var plannerCollectionView: UICollectionView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var navigateToPlannerButton: UIButton!
    
    var plannerList = [Planner]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlannerCollection), name: .didCreateNewPlanner, object: nil)
        
        // 여행 카드, 여행 추가하기 버튼 Xib 연결
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerCollectionViewCell.self)))
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerAddButtonCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerAddButtonCollectionViewCell.self)))
        
        // Data Source, Delegate 지정
        plannerCollectionView.dataSource = self
        plannerCollectionView.delegate = self
        
        // 컬렉션 뷰 레이아웃 지정
        plannerCollectionView.collectionViewLayout = CollectionViewLayout.setGridLayoutWithRatio(
            columns: 2,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8),
            ratioX: 3.0,
            ratioY: 4.0
        )
        
        // 등록된 여행이 하나도 없을 시 Placeholder 를 보여주기 위해 화면 진입 시 CoreData에서 데이터 갯수 체크
        let fetchedListCount = CoreDataManager.shared.fetchPlannerCount()
        
        if fetchedListCount > 0 {
            let entities = CoreDataManager.shared.fetchAllPlanners()
            let planners = entities.compactMap { Planner(entity: $0) }
            plannerList = planners
            
            errorMessageLabel.isHidden = true
            navigateToPlannerButton.isHidden = true
        } else {
            errorMessageLabel.isHidden = false
            navigateToPlannerButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func reloadData() {
        let fetchedListCount = CoreDataManager.shared.fetchPlannerCount()
        
        if fetchedListCount > 0 {
            let entities = CoreDataManager.shared.fetchAllPlanners()
            plannerList = entities.compactMap { Planner(entity: $0) }
            errorMessageLabel.isHidden = true
            navigateToPlannerButton.isHidden = true
        } else {
            plannerList = []
            errorMessageLabel.isHidden = false
            navigateToPlannerButton.isHidden = false
        }
        
          print("=== 플래너 목록 ===")
          for planner in plannerList {
              print("제목: \(planner.title), 썸네일 경로: \(planner.thumbnailPath ?? "없음")")
          }
        
        plannerCollectionView.reloadData()
    }
    
    @objc func reloadPlannerCollection() {
        self.plannerCollectionView.reloadData()
    }
    
    private func navigateToDetailView(id: UUID) {
        let plannerEditorStoryboard = UIStoryboard(name: "PlannerEditor", bundle: nil)
        
        print("🆔 전달된 planner id: \(id)")
        
        if let detailVC = plannerEditorStoryboard.instantiateViewController(withIdentifier: "PlannerEditorVC") as? PlannerEditorViewController {
            detailVC.plannerID = id
            self.navigationController?.pushViewController(detailVC, animated: true)
            
            // TODO: PlannerEditorVC에 분기를 처리하는 코드 작업 완료 시 id 값 넘기기
//             detailVC.id = id
        }
    }
}

extension PlannerViewController: UICollectionViewDelegate {
    // 컬렉션 셀 선택 시 처리할 동작 정의
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let planner = plannerList[indexPath.item]
        let id = planner.id
        
        // 여행 카드 선택 시 CoreData를 조회, 여행이 존재할 경우 Detail 페이지로 이동
        Task {
            if let planner = CoreDataManager.shared.fetchOnePlanner(id: id) {
                navigateToDetailView(id: planner.id!)
            } else {
                // 여행이 없을 시 alert 띄우기
                let alert = UIAlertController(title: "여행 자세히 보기 실패", message: "선택하신 여행에 대한 정보를 찾을 수 없어요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension PlannerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let plannerCount = plannerList.count
        
        if plannerCount > 0 {
            // 여행 추가하기 버튼을 만들기 위해 셀 갯수를 여행 갯수 + 1로 지정
            return plannerList.count + 1
        } else {
            return 0
        }
    }
    
    // 마지막 셀은 여행 추가하기 버튼이 돼야 하므로 셀 등록 시 조건에 따라 맞는 셀을 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if plannerList.count == indexPath.item {
            // 마지막 셀일 경우 여행 추가하기 셀 등록
            let addPlannerCell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerAddButtonCollectionViewCell.self), for: indexPath) as! PlannerAddButtonCollectionViewCell
            
            // 여행 추가하기 버튼 터치 액션 재정의
            addPlannerCell.onTab = { [weak self] in
                self?.performSegue(withIdentifier: "navigateToPlannerCompositionView", sender: indexPath)
            }
            
            return addPlannerCell
        } else {
            // 그 외의 경우 기본 여행 셀 등록
            let cell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerCollectionViewCell.self), for: indexPath) as! PlannerCollectionViewCell
            
            let planner = plannerList[indexPath.item]
            cell.planner = planner
            
            if let imagePath = planner.thumbnailPath {
                let imageURL = URL(fileURLWithPath: imagePath)
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    let image = UIImage(contentsOfFile: imageURL.path)
                    cell.plannerThumbnailImageView.image = image
                } else {
//                    print("현재 임시 폴더 주소: \(FileManager.default.temporaryDirectory)")
//                    print("파일 주소        : file://\(imageURL.path)")
                }
            }
            
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
