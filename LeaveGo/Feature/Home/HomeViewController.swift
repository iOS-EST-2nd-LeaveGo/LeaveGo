//
//  HomeViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

class HomeViewController: UIViewController {
    // 데이터 모델링 테스트를 위한 코드
    var places = [PlaceList]()
    
    func runAPITestForLocationBasedEndpoint(mapX: Double, mapY: Double, radius: Int) async {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return }
        
        let baseUrl = "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json"
        
        guard let url = URL(string: "\(baseUrl)&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&serviceKey=\(apikey)") else { return }

        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                
                do {
                    let responseRoot = try decoder.decode(ResponseRoot<PlaceList>.self, from: data)
                    self.places = responseRoot.response.body.items.item
                } catch {
                    print("Decode 에러: \(error.localizedDescription)")
                }
            default:
                print("HTTP 오류 코드: \(httpResponse.statusCode)")
                return
            }
        } catch {
            print("네트워크 오류: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await runAPITestForLocationBasedEndpoint(mapX: 127.0541534400073, mapY: 37.73755263999631, radius: 2000)
        }
    }
}
