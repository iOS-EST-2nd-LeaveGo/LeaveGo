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
    
    // 등록된 여행이 하나도 없을 때 보여줄 Placeholder 텍스트
    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 등록된 여행이 없어요"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true // 초기에는 숨김
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 더미 데이터 주입
        // plannerList = mockPlanners
        
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerCollectionViewCell.self)))
        plannerCollectionView.register(UINib(nibName: String(describing: PlannerAddButtonCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: String(describing: PlannerAddButtonCollectionViewCell.self)))
        
        plannerCollectionView.dataSource = self
        
        plannerCollectionView.collectionViewLayout = CollectionViewLayout.grid(
            columns: 2,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        )
        
        let fetchedListCount = CoreDataManager.shared.fetchPlannerCount()
        if fetchedListCount > 0 {
            let entities = CoreDataManager.shared.fetchAllPlanners()
            let planners = entities.compactMap { Planner(entity: $0) }
            print(plannerList)
            plannerList = planners
        } else {
            print("no data")
            view.addSubview(errorMessageLabel)
            
            NSLayoutConstraint.activate([
                errorMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            errorMessageLabel.isHidden = true
        }
    }
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
            
            if let thumnailPathExisting = planner.thumbnailPath {
                cell.plannerThumbnailImageView.image = UIImage(named: thumnailPathExisting)
            }
            
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
