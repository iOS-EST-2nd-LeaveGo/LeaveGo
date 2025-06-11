//
//  NetworkManager.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/10/25.
//

import Foundation

class NetworkManager {
    // 싱글톤 타입으로 선언
    static let shared = NetworkManager()
    
    // endpoint 에서 반환하는 url 을 가지고 request 생성
    func makeRequest(endpoint: Endpoint) throws -> URLRequest {
        if let url = endpoint.url {
            return URLRequest(url: url)
        } else {
            print("😵 URLRequest 생성 실패")
            throw NetworkError.invalidURL
        }
    }
    
    // request 와 디코딩 타입을 가지고 API 호출
    func performRequest<T: Decodable>(urlRequest: URLRequest, type: T.Type) async throws -> T? {
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                let decoder = JSONDecoder()
                
                do {
                    let decodedData = try decoder.decode(type, from: data)
                    return decodedData
                } catch {
                    print("😵 Decode 에러: \(error), \(error.localizedDescription)")
                    throw NetworkError.decodingError
                }
            } else {
                print("😵 HTTP 오류 코드: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
        } catch {
            print("😵 알 수 없는 네트워크 오류: \(error), \(error.localizedDescription)")
            throw NetworkError.unKnown
        }
    }
}
