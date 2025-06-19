//
//  TransportSelectionViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

// MARK: - 선호 교통수단 선택 화면 (온보딩 또는 수정 모드)
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
        
        // 컬렉션 뷰 레이아웃 구성
        transportCollectionView.collectionViewLayout = CollectionViewLayout.setGridLayoutWithRatio(
            columns: 3,
            itemInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        )
        
        // cell 등록
        transportCollectionView.register(UINib(nibName: "PreferenceItemCell", bundle: nil), forCellWithReuseIdentifier: "PreferenceItemCell")
        
        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true
        
        // 수정 모드 시 기존 선택값 및 UI 조정
        if mode == .editing {
            navigationItem.rightBarButtonItem?.isHidden = true
            
            navigationItem.title = "이동 수단 변경"
            
            titleLabel.isHidden = true
            
            saveButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        }
    }
    
    
    // MARK: - 저장된 교통수단을 선택 상태로 복원
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if mode == .editing {
            if let savedTransport = UserSetting.shared.preferredTransport,
               let index = TransportType.allCases.firstIndex(of: savedTransport) {
                
                let indexPath = IndexPath(item: index, section: 0)
                transportCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                saveButton.isEnabled = true
            }
        }
    }
    
    deinit {
        //        print("TransportViewController 해제완료")
    }
}

// MARK: - UICollectionViewDataSource: 셀 개수 및 구성
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

// MARK: - UICollectionViewDelegate: 셀 선택 시 상태 반영
extension TransportViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTransport = TransportType.allCases[indexPath.item]
        saveButton.isEnabled = true
    }
}
