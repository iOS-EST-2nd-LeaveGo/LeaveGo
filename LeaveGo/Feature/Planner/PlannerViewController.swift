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
        
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerCollectionViewCell.self)))
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerAddButtonCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerAddButtonCollectionViewCell.self)))
        
        plannerCollectionView.dataSource = self
        
        plannerCollectionView.collectionViewLayout = CollectionViewLayout.setGridLayoutWithRatio(
            columns: 2,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8),
            ratioX: 3.0,
            ratioY: 4.0
        )
        
        let fetchedListCount = CoreDataManager.shared.fetchPlannerCount()
        if fetchedListCount > 0 {
            let entities = CoreDataManager.shared.fetchAllPlanners()
            let planners = entities.compactMap { Planner(entity: $0) }
            plannerList = planners
            errorMessageLabel.isHidden = true
            errorMessageLabel.isHidden = true
        } else {
            navigateToPlannerButton.isHidden = false
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
            addPlannerButton.isHidden = true
        } else {
            plannerList = []
            errorMessageLabel.isHidden = false
            addPlannerButton.isHidden = false
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
    
}

extension PlannerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let plannerCount = plannerList.count
        
        if plannerCount > 0 {
            return plannerList.count + 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if plannerList.count == indexPath.item {
            let addPlannerCell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerAddButtonCollectionViewCell.self), for: indexPath) as! PlannerAddButtonCollectionViewCell
            
            addPlannerCell.onTab = { [weak self] in
                self?.performSegue(withIdentifier: "navigateToPlannerCompositionView", sender: indexPath)
            }
            
            return addPlannerCell
        } else {
            let cell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerCollectionViewCell.self), for: indexPath) as! PlannerCollectionViewCell
            
            let planner = plannerList[indexPath.item]
            cell.planner = planner

            if let thumnailPathExisting = planner.thumbnailPath {
                cell.plannerThumbnailImageView.image = UIImage(named: thumnailPathExisting)
            }
            
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
