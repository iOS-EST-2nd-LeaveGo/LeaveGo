//
//  MapHeaderView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import UIKit

class MapHeaderViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var displaySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentContentView: UIView!
    
    var placeListVC: PlacesViewController = {
        let vc = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesVC") as! PlacesViewController
        return vc
    }()
    var mapVC: MapViewController = {
        let vc = MapViewController()
        return vc
    }()
    
    private var currentVC: UIViewController?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentVC = placeListVC
        
        displaySegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        switchToVC(placeListVC)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToVC(placeListVC)
        } else {
            switchToVC(mapVC)
        }
    }
    
    func switchToVC(_ newVC: UIViewController) {
        // 현재 VC 제거
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // 새 VC 추가
        addChild(newVC)
        newVC.view.frame = segmentContentView.bounds
        segmentContentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        currentVC = newVC
    }
    
}
