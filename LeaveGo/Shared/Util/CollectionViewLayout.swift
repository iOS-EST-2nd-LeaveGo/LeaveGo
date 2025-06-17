//
//  CollectionViewLayout.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

import UIKit

enum CollectionViewLayout {
    static func grid(
        columns: CGFloat,
        itemInsets: NSDirectionalEdgeInsets,
        groupInsets: NSDirectionalEdgeInsets,
        sectionInsets: NSDirectionalEdgeInsets
    ) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / columns),
            heightDimension: .fractionalWidth(1.0 / columns)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemInsets

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / columns)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = groupInsets

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func threeByFourGrid(
        columns: CGFloat,
        itemInsets: NSDirectionalEdgeInsets,
        groupInsets: NSDirectionalEdgeInsets,
        sectionInsets: NSDirectionalEdgeInsets
    ) -> UICollectionViewLayout {
        let itemWidthFraction = 1.0 / columns
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemWidthFraction),
            heightDimension: .fractionalWidth(itemWidthFraction * 4.0 / 3.0) // ← 3:4 비율
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemInsets

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(itemWidthFraction * 4.0 / 3.0) // ← group도 아이템 높이에 맞춤
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = groupInsets

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets

        return UICollectionViewCompositionalLayout(section: section)
    }
}
