//
//  TransportSelectionViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class TransportViewController: UIViewController {
    private var selectedTransport: TransportType?

    @IBOutlet weak var transportCollectionView: UICollectionView!

    @IBAction func saveTransport(_ sender: Any) {
        guard let transport = selectedTransport else {
            return
        }

        UserSetting.shared.preferredTransport = transport
        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")

        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBar = mainSB.instantiateViewController(withIdentifier: "MainTabBarController")

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first {
            window.rootViewController = mainTabBar
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //        //test
        //        print(UserSetting.shared.nickname)
        //        print(UserSetting.shared.preferredTransport?.rawValue)

        navigationItem.backButtonTitle = ""

        // 레이아웃 설정
        transportCollectionView.collectionViewLayout = threeColumnGridLayout()
//        transportCollectionView.allowsMultipleSelection = true

        // cell 등록
        transportCollectionView.register(UINib(nibName: "PreferenceItemCell", bundle: nil), forCellWithReuseIdentifier: "PreferenceItemCell")

    }

    // CompositionalLayout을 활용한 3열 그리드 생성
    // 재활용시 리팩토리 작업 필요
    private func threeColumnGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalWidth(1.0/3.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
//        section.interGroupSpacing = 8

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

extension TransportViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTransport = TransportType.allCases[indexPath.item]
    }
}
