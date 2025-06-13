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
        
        // 더미 데이터 주입
        plannerList = mockPlanners
        
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerCollectionViewCell.self)))
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerAddButtonCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerAddButtonCollectionViewCell.self)))
        
        plannerCollectionView.delegate = self
        plannerCollectionView.dataSource = self
        
        plannerCollectionView.collectionViewLayout = CollectionViewLayout.grid(
            columns: 2,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        )
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
            
            addPlannerCell.onTab = { [weak self] in
                self?.performSegue(withIdentifier: "navigateToPlannerCompositionView", sender: indexPath)
            }
            
            return addPlannerCell
        } else {
            let cell = plannerCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlannerCollectionViewCell.self), for: indexPath) as! PlannerCollectionViewCell
            
            let planner = plannerList[indexPath.item]
            
            if let thumnailPathExisting = planner.thumnailPath {
                cell.plannerThumbnailImageView.image = UIImage(named: thumnailPathExisting)
            }
            
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
