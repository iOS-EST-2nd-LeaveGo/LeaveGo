//
//  LocationManager.swift
//  LeaveGo
//
//  Created by 김효환 on 6/9/25.
//

import Foundation
import CoreLocation
import UIKit

final class LocationManager: NSObject {
    // 싱글톤
    static let shared = LocationManager()

    let manager = CLLocationManager()

    private(set) var currentLocation: CLLocationCoordinate2D?

    private override init() {
        super.init()

        manager.delegate = self
        // 위치관련 정보를 받기위해선 무조건 호출되어야 합니다.
        // 설정한 plist에 따라서 requestAlwaysAuthorization로도 사용이 가능합니다.
        // 이 메서드만 따로 빼서, 실행해줘도 되요!
        manager.requestWhenInUseAuthorization()
        // 위치 정확도 (여기선 배터리 상황에 따른 최적의 정확도로 설정)
        manager.distanceFilter = 5
        // 5미터 이동할 때 마다 gps를 update합니다.
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func setConfiguration(_ configuration: (CLLocationManager) -> Void) {
        configuration(manager)
    }

    func startUpdating() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func requestSingleLocation() {
        let status = manager.authorizationStatus

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

}

extension UIApplication {
    func getKeyWindowRootViewController() -> UIViewController? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 사용자의 최신 위치 정보를 가져옵니다.
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        NotificationCenter.default.post(name: .locationDidUpdate, object: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        NotificationCenter.default.post(name: .headingDidUpdate, object: newHeading)
    }

    // 잠재적인 오류에 응답하기 위해서 생성
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to Fetch Location (\(error))")
        NotificationCenter.default.post(name: .locationUpdateDidFail, object: error)
    }

    // 현재 인증 상태 확인
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치상태: 허용")
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()

        case .denied, .restricted:
            print("위치상태: 허용안됨")
            manager.stopUpdatingLocation()

            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "떠나고를 이용하기 위해서는 위치 권한이 필요합니다",
                    message: "정확한 위치 제공을 위해 설정에서 위치 접근을 허용해 주세요.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in

                    if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                })

                UIApplication.shared.getKeyWindowRootViewController()?.present(alert, animated: true)
            }
        case .notDetermined:
            print("위치상태: 결정되지 않음")
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

