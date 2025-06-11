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
            try await NetworkManager.shared.fetchPlaceList(mapX: 127.0541534400073, mapY: 37.73755263999631, radius: 2000)
//            await runAPITestForPlaceDetailEndpoint(contentId: 126128, contentTypeId: 12)
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
    
    func runAPITestForPlaceDetailEndpoint(contentId: Int, contentTypeId: Int) async {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return }
        
        let baseUrl = "https://apis.data.go.kr/B551011/KorService2/detailIntro2?MobileOS=IOS&MobileApp=LeaveGo&_type=json"
        
        guard let url = URL(string: "\(baseUrl)&contentId=\(contentId)&contentTypeId=\(contentTypeId)&serviceKey=\(apikey)") else { return }

        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                
                do {
                    let responseRoot = try decoder.decode(ResponseRoot<PlaceDetail>.self, from: data)
                    print("🙆‍♀️ API 호출 성공: \n\(responseRoot.response.body.items)")
                } catch {
                    print("😵 Decode 에러: \(error)")
                }
            default:
                print("😵 HTTP 오류 코드: \(httpResponse.statusCode)")
                return
            }
        } catch {
            print("😵 네트워크 오류: \(error)")
        }
    }


}
