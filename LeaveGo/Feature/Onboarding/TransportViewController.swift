//
//  TransportSelectionViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class TransportViewController: UIViewController {
    var mode: TransportMode = .onboarding

    private var selectedTransport: TransportType?

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var transportCollectionView: UICollectionView!

    @IBOutlet weak var saveButton: UIButton!

    @IBAction func saveTransport(_ sender: Any) {
        guard let transport = selectedTransport else {
            return
        }

        UserSetting.shared.preferredTransport = transport
        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")

        switch mode {
        case .onboarding:
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBar = mainSB.instantiateViewController(withIdentifier: "MainTabBarController")

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = mainTabBar
            }
        case .editing:
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""
        saveButton.isEnabled = false
        // 레이아웃 설정

        transportCollectionView.collectionViewLayout = CollectionViewLayout.setGridLayoutWithRatio(
            columns: 3,
            itemInsets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )

        //        transportCollectionView.allowsMultipleSelection = true

        // cell 등록
        transportCollectionView.register(UINib(nibName: "PreferenceItemCell", bundle: nil), forCellWithReuseIdentifier: "PreferenceItemCell")

        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.clipsToBounds = true
        
        if mode == .editing {
            navigationItem.rightBarButtonItem?.isHidden = true

            navigationItem.title = "이동 수단 변경"

            titleLabel.isHidden = true

            saveButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if mode == .editing,
           let savedTransport = UserSetting.shared.preferredTransport,
           let index = TransportType.allCases.firstIndex(of: savedTransport) {

            let indexPath = IndexPath(item: index, section: 0)

            transportCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

            saveButton.isEnabled = true
        }
    }

    deinit {
//        print("TransportViewController 해제완료")
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
        saveButton.isEnabled = true
    }
}
