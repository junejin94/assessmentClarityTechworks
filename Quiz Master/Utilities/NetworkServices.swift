//
//  NetworkServices.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Foundation

/// Singleton for network services.
class NetworkServices {
  static let shared = NetworkServices()
  private let session = URLSession.shared

  private init() {}

  /**
   Fetch quizzes from the Open Trivia Database

   - Parameters:
      - amount: The amount of questions (max. 50)
      - category: The category of questions
      - difficulty: The difficulty of the questions
      - type: The type of questions

   - Returns: A list of users.
   */
  func fetchQuiz(amount: Int, category: Int, difficulty: Int, type: Int) async throws -> QuizResponse {
    return try await request(endpoint: Endpoint.quiz(amount: amount, category: category, difficulty: difficulty, type: type), type: QuizResponse.self)
  }

  /**
     Fetch data from the Endpoint struct.
     .
     - Parameters:
        - endpoint: Endpoint struct that contains the URL requests
        - type: The codable type that will be decoded into

     - Returns: Codable object based on type
     */
  private func request<T: Codable>(endpoint: Endpoint, type: T.Type) async throws -> T {
    guard let url = endpoint.url else { throw EndpointError.missingEndpointURL(endpoint: endpoint) }

    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method

    let (data, _) = try await NetworkServices.shared.session.data(for: request)
    let decoded = try JSONDecoder().decode(type, from: data)

    return decoded
  }
}

/**
 Manage endpoints and generate URL object.

 The current list of endpoint supported,
 - api
 */
struct Endpoint {
  let path: String
  let method: String = "GET"
  let queryItems: [URLQueryItem]?

  static func quiz(amount: Int, category: Int, difficulty: Int, type: Int) -> Endpoint {
    var queryItems: [URLQueryItem] = []

    if amount != 0 {
      queryItems.append(URLQueryItem(name: QuizConfiguration.amount.rawValue, value: String(amount)))
    }

    if category != 0 {
      queryItems.append(URLQueryItem(name: QuizConfiguration.category.rawValue, value: String(category)))
    }

    if difficulty != 0 {
      queryItems.append(URLQueryItem(name: QuizConfiguration.difficulty.rawValue, value: QuizDifficulty.allCases[difficulty].rawValue))
    }

    if type != 0 {
      queryItems.append(URLQueryItem(name: QuizConfiguration.type.rawValue, value: QuizType.allCases[type].rawValue))
    }

    return Endpoint(path: Subpath.api.path, queryItems: queryItems)
  }

  var url: URL? {
    let scheme = "https"
    let host = "opentdb.com"

    var components = URLComponents()

    components.scheme = scheme
    components.host = host
    components.path = path
    components.queryItems = queryItems

    return components.url
  }
}

// MARK: - Enum
private enum Subpath {
  case api

  var path: String {
    switch self {
    case .api:
      return "/api.php"
    }
  }
}

private enum QuizConfiguration: String {
  case amount
  case category
  case difficulty
  case type
}
