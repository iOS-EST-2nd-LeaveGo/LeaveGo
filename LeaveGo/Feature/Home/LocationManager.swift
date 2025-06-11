//
//  LocationManager.swift
//  LeaveGo
//
//  Created by 김효환 on 6/9/25.
//

import Foundation
import CoreLocation

final class LocationManager: CLLocationManager {
    
    // 싱글톤
    static let shared = LocationManager()
    
    typealias FetchLocationCompletion = (CLLocationCoordinate2D?, Error?) -> Void

    // 동작을 담아주기 위해 클로저를 만들어 줌
    private var fetchLocationCompletion: FetchLocationCompletion?
    
    override init() {
        super.init()
        
        self.delegate = self
        // 위치관련 정보를 받기위해선 무조건 호출되어야 합니다.
        // 설정한 plist에 따라서 requestAlwaysAuthorization로도 사용이 가능합니다.
        // 이 메서드만 따로 빼서, 실행해줘도 되요!
        self.requestWhenInUseAuthorization()
        // 위치 정확도 (여기선 배터리 상황에 따른 최적의 정확도로 설정)
        self.distanceFilter = 5
        // 5미터 이동할 때 마다 gps를 update합니다.
        self.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// 현재 사용자 위치 업데이트
    ///
    /// 이 메서드를 여러 번 호출해도 새 이벤트가 생성되지 않으므로, 새로운 이벤트를 받으러면, 꼭 stopUpdatingLocation을 사용 후 사용해야 합니다.
    override func startUpdatingLocation() {
            super.startUpdatingLocation()
            super.startUpdatingHeading()
    }
    
    /// 위치 업데이트 생성 중지
    override func stopUpdatingLocation() {
        super.stopUpdatingLocation()
    }

    /// 현재 위치를 딱 한번만 전달합니다. (그런데 위치를 받는게 뭔가 느리다)
    override func requestLocation() {
        super.requestLocation()
    }
    
    /// 위치 권한 상태에 따라 위치 요청을 수행하는 메서드
    ///
    /// - 권한이 있는 경우: 즉시 위치 요청 수행
    /// - 권한이 없는 경우: 권한 요청 후 위치 요청은 별도로 수행 필요
    /// - 거부된 경우: 에러 클로저 호출
    func fetchLocation(completion: @escaping FetchLocationCompletion) {
        // 클로저를 저장하여 위치 업데이트 결과를 나중에 전달할 수 있게 보관
        self.fetchLocationCompletion = completion

        // 현재 위치 권한 상태 확인
        let status = self.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // 위치 권한이 허용된 경우, 위치 요청 수행
            self.requestLocation()

        case .notDetermined:
            // 아직 권한이 결정되지 않은 경우, 권한 요청 수행
            // 사용자가 '허용'을 누르면 `locationManagerDidChangeAuthorization`에서 requestLocation() 호출됨
            self.requestWhenInUseAuthorization()

        default:
            // 권한이 거부되었거나 제한된 경우, 에러 클로저 호출
            let error = NSError(
                domain: "LocationError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "위치 권한이 필요합니다."]
            )
            completion(nil, error)
        }
    }

}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 사용자의 최신 위치 정보를 가져옵니다.
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        
        // coordinate 값을 갖고 저장 한, 동작을 실행
        self.fetchLocationCompletion?(coordinate, nil)
        // 위의 실행 후 클로저 초기화
        self.fetchLocationCompletion = nil
        
//        print("test : \(locations.last)")
    }
    
    // 잠재적인 오류에 응답하기 위해서 생성
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to Fetch Location (\(error))")
        
        // 에러발생 시 저장된 값을 갖고 동작을 실행
        self.fetchLocationCompletion?(nil, error)
        // 위의 실행 후 클로저 초기화
        self.fetchLocationCompletion = nil
    }
    
    // 현재 인증 상태 확인
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways , .authorizedWhenInUse:
            print("위치상태 : 허용")
            // 인증 메세지 늦게 클릭하면 처음 업데이트 되는 데이터를 못받게 됨.
            // (그래서 권한을 확인으로 설정 시, 위치를 한 번 받아 줬다)
            self.startUpdatingLocation()
        case .notDetermined , .denied , .restricted:
            print("위치상태: 허용안됨")
            self.stopUpdatingLocation()
        default: break
        }
    }
}
