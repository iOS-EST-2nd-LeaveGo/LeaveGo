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

// MARK: LayoutSupport
//extension MapHeaderViewController: LayoutSupport {
//  func addSubviews() {
//    self.view.addSubview(containerView)
//    
//    containerView.addSubview(stackView)
//    
//    stackView.addArrangedSubview(searchTextFieldBackbroundView)
//    stackView.addArrangedSubview(displaySegmented)
//    
//    searchTextFieldBackbroundView.addSubview(searchTextField)
//  }
//  
//  func setupSubviewsConstraints() {
//    containerView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
//      containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//      containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//      containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//    ])
//    
//    stackView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
//      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
//    ])
//    
//    searchTextFieldBackbroundView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      searchTextFieldBackbroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
//      searchTextFieldBackbroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
//      searchTextFieldBackbroundView.heightAnchor.constraint(equalToConstant: 40)
//    ])
//    
//    searchTextField.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      searchTextField.centerYAnchor.constraint(equalTo: searchTextFieldBackbroundView.centerYAnchor),
//      searchTextField.leadingAnchor.constraint(equalTo: searchTextFieldBackbroundView.leadingAnchor, constant: 16),
//      searchTextField.trailingAnchor.constraint(equalTo: searchTextFieldBackbroundView.trailingAnchor, constant: -16)
//    ])
//  }
//  
//}
