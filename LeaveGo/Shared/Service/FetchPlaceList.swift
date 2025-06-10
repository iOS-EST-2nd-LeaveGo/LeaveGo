//
//  FetchPlaceList.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/10/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchPlaceList(mapX: Double, mapY: Double, radius: Int) async throws -> [PlaceList]? {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return nil }
        
        let baseUrl = "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json"
        
        guard let url = URL(string: "\(baseUrl)&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&serviceKey=\(apikey)") else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                
                do {
                    let responseRoot = try decoder.decode(ResponseRoot<PlaceList>.self, from: data)
                    let placeList = responseRoot.response.body.items.item
                    print("🙆‍♀️ API 호출 성공: \n\(placeList)")
                    return placeList
                } catch {
                    print("😵 Decode 에러: \(error)")
                }
            default:
                print("😵 HTTP 오류 코드: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
        } catch {
            print("😵 네트워크 오류: \(error)")
            throw NetworkError.invalidResponse
        }
        
        return nil
    }
}
