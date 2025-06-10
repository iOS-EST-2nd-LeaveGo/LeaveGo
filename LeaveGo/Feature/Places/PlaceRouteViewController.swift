//
//  PlaceRouteViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class PlaceRouteViewController: UIViewController {

    @IBOutlet weak var locationContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        locationContainer.layer.cornerRadius = 10
        locationContainer.clipsToBounds = true
    }
}
