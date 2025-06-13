//
//  PlannerViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

class PlannerViewController: UIViewController {
    @IBOutlet weak var plannerCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        plannerCollectionView.register(UINib(nibName: "PlannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PlannerItemCell")
        
        plannerCollectionView.delegate = self
        plannerCollectionView.dataSource = self
    }
    
    deinit {
        print("plannerCollectionView 해제완료")
    }
}

extension PlannerViewController: UICollectionViewDelegate {
    
}

extension PlannerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let planners = [Planner]()
        
        return UICollectionViewCell()
    }
}
