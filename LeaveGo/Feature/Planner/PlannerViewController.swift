//
//  PlannerViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

class PlannerViewController: UIViewController {
    @IBOutlet weak var plannerCollectionView: UICollectionView!
    
    var plannerList = [Planner]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in (0...2) {
            plannerList.append(mockPlanner)
        }
        
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerCollectionViewCell.self)))
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerAddButtonCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerAddButtonCollectionViewCell.self)))
        print(PlannerCollectionViewCell.self)
        print(PlannerAddButtonCollectionViewCell.self)
        
        plannerCollectionView.delegate = self
        plannerCollectionView.dataSource = self
        
        plannerCollectionView.collectionViewLayout = CollectionViewLayout.grid(
            columns: 2,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        )
    }
    
    deinit {
        print("plannerCollectionView 해제완료")
    }
}

extension PlannerViewController: UICollectionViewDelegate {
    
}

extension PlannerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plannerList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if plannerList.count == indexPath.item {
            let addPlannerCell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerAddButtonCollectionViewCell.self), for: indexPath) as! PlannerAddButtonCollectionViewCell
            
            return addPlannerCell
        } else {
            let cell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerCollectionViewCell.self), for: indexPath) as! PlannerCollectionViewCell
            
            let planner = plannerList[indexPath.item]
            
            cell.plannerThumbnailImageView.image = UIImage(named: planner.thumnailPath ?? "pencil")
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
