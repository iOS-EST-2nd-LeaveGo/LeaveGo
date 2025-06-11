//
//  HomeViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        
        Task {
//            try await NetworkManager.shared.fetchPlaceList(mapX: 127.0541534400073, mapY: 37.73755263999631, radius: 2000)
            try await NetworkManager.shared.fetchPlaceDetail(contentId: 126128, contentTypeId: 12)
        }
    }
    
    func setupLocation() {
        // 싱글톤
        LocationManager.shared.fetchLocation { [weak self] (location, error) in
            guard let self = self else { return }
            
            if let location = location {
                self.location = location
                print("📍 사용자 위치 - 위도: \(location.latitude), 경도: \(location.longitude)")
            } else if let error = error {
                print("❌ 위치 가져오기 실패: \(error.localizedDescription)")
            } else {
                print("⚠️ 알 수 없는 오류 발생")
            }
        }
    }
    
}
