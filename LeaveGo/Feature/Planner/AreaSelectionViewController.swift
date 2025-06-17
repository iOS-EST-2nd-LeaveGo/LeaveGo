//
//  AreaSelectionViewController.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/13/25.
//

import UIKit

class AreaSelectionViewController: UIViewController {
    @IBOutlet weak var areaSelectionCollectionView: UICollectionView!
    @IBOutlet weak var selectButtonView: UIButton!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PlaceSelectionTableViewController {
            guard selectedArea != nil else { return }
            
            vc.area = selectedArea!
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurEffectView.applyFeatherMask(to: blurEffectView)
    }
    
    var selectedArea: Area?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        areaSelectionCollectionView.register(UINib(nibName: String(describing: AreaSelectionCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AreaSelectionCollectionViewCell.self))
        
        areaSelectionCollectionView.delegate = self
        areaSelectionCollectionView.dataSource = self
        areaSelectionCollectionView.collectionViewLayout = CollectionViewLayout.grid(
            columns: 3,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        )
        
        selectButtonView.isEnabled = false
        
        areaSelectionCollectionView.allowsSelection = true
        areaSelectionCollectionView.allowsMultipleSelection = false
    }
}

extension AreaSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedArea = Area.allCases[indexPath.item]
        selectButtonView.isEnabled = true
        selectButtonView.backgroundColor = selectButtonView.isEnabled ? UIColor.accent : UIColor.gray
        selectButtonView.layer.cornerRadius = 16
        selectButtonView.clipsToBounds = true
    }
}

extension AreaSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Area.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = areaSelectionCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AreaSelectionCollectionViewCell.self), for: indexPath) as! AreaSelectionCollectionViewCell
        
        let area = Area.allCases[indexPath.item]
        cell.areaNameLabel.text = area.name
        cell.areaNameContainer.backgroundColor = .customBackground
        
        return cell
    }
}
