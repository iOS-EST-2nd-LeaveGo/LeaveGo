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
        label.text = "아직 등록된 여행이 없어요."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true // 초기에는 숨김
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let addPlannerButton: UIButton = {
        let button = UIButton()
        button.setTitle("새로운 여행 등록하기", for: .normal)
        button.layer.borderColor = UIColor.accent.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.textColor = UIColor.accent
        button.isHidden = true // 초기에는 숨김
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            errorMessageLabel.isHidden = false
            
            view.addSubview(errorMessageLabel)
            view.addSubview(addPlannerButton)
            
            NSLayoutConstraint.activate([
                errorMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
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
            
            if let thumnailPathExisting = planner.thumbnailPath {
                cell.plannerThumbnailImageView.image = UIImage(named: thumnailPathExisting)
            }
            
            cell.plannerTitleLabelView.text = planner.title
            
            return cell
        }
    }
}
