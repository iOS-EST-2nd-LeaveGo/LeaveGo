//
//  NetworkError.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/10/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case unKnown
}
