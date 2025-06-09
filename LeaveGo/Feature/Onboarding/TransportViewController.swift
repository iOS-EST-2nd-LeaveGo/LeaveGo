//
//  TransportSelectionViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class TransportViewController: UIViewController {

    @IBOutlet weak var transportCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        transportCollectionView.collectionViewLayout = threeColumnGridLayout()
        transportCollectionView.allowsMultipleSelection = true

        transportCollectionView.register(UINib(nibName: "PreferenceItemCell", bundle: nil), forCellWithReuseIdentifier: "PreferenceItemCell")

    }

    private func threeColumnGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalWidth(1.0/3.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension TransportViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TransportType.allCases.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreferenceItemCell", for: indexPath) as! PreferenceItemCell

        let item = TransportType.allCases[indexPath.item]
        cell.setup(with: item)

        return cell
    }
}
