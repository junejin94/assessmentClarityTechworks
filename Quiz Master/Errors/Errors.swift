//
//  Errors.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Foundation

/// Error related to Database
enum DatabaseError: LocalizedError {
    case emptyDatabase
    case invalidEntity
    case unableToRead

    var errorDescription: String? {
        switch self {
        case .emptyDatabase:
          return "The database is empty, will attempt to fetch from web"

        case .invalidEntity:
          return "Invalid Entity"

        case .unableToRead:
          return "Unable to read the database"
        }
    }
}

enum ScoresError: LocalizedError {
  case emptyScores

  var errorDescription: String? {
    switch self {
    case .emptyScores:
      return "Scores is empty"
    }
  }
}

/// Error related to Endpoint
enum EndpointError: LocalizedError {
  case missingEndpointURL(endpoint: Endpoint)

  var errorDescription: String? {
    switch self {
    case let .missingEndpointURL(endpoint):
      "The URL is missing for Endpoint: \(endpoint)"
    }
  }
}

/// Error related to Network
enum NetworkError: LocalizedError {
  case unexpectedError
  case invalidURL(url: String)
  case failedToDownloadFile(url: String)

  var errorDescription: String? {
    switch self {
    case .unexpectedError:
      "Unexpected error"

    case let .invalidURL(url):
      "Invalid URL: \(url)"

    case let .failedToDownloadFile(url):
      "Failed to download image from: \(url)"
    }
  }
}

/// Error related to Open Trivia Database
enum OpenTriviaDatabaseError: LocalizedError {
  case noResults
  case invalidParameter
  case tokenNotFound
  case tokenEmpty
  case rateLimit

  var errorDescription: String? {
    switch self {
    case .noResults:
      "Could not return results. The API doesn't have enough questions for your query"

    case .invalidParameter:
      "Contains an invalid parameter. Arguements passed in aren't valid"

    case .tokenNotFound:
      "Session Token does not exist"

    case .tokenEmpty:
      "Session Token has returned all possible questions for the specified query. Resetting the Token is necessary"

    case .rateLimit:
      "Too many requests have occurred. Each IP can only access the API once every 5 seconds"
    }
  }
}
