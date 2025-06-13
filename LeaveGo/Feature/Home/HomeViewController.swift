//
//  HomeViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    // 장소 목록 & 상세 호출 예시
    var placeList = [PlaceList]()
    var placeDetail: PlaceDetail?
    
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        
        Task {
            // 장소 목록 호출 예시
            if let APIPlaceList = try await NetworkManager.shared.fetchPlaceList(page: 1, mapX: 126.76892949097858, mapY: 37.50998540622347, radius: 2000) {
                placeList = APIPlaceList
                print("🏠 HomeView: \(placeList)")
            }
            
            // 장소 상세 호출 예시
            if let APIPlaceDetail = try await NetworkManager.shared.fetchPlaceDetail(contentId: 126128) {
                placeDetail = APIPlaceDetail
                print("🏠 HomeView: \(String(describing: placeDetail!))")
            }
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
