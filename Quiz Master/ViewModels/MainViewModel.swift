//
//  MainViewModel.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Combine
import Foundation
import UIKit

class MainViewModel: ObservableObject {
  private let totalQuestions = 5

  private let listCategory = QuizCategory.allCases
  private let listCategoryDesc = QuizCategory.allCases.map(\.description)

  private let listDifficulties = QuizDifficulty.allCases
  private let listDifficultiesDesc = QuizDifficulty.allCases.map(\.description)

  private let listType = QuizType.allCases
  private let listTypeDesc = QuizType.allCases.map(\.description)

  @Published private(set) var category = 0
  @Published private(set) var difficulty = 0
  @Published private(set) var type = 0

  @Published private(set) var isLoading = false
  @Published private(set) var fetchedQuiz: QuizViewModel?

  @Published var showError = false

  private(set) var errorMessage: String?

  func title(_ tag: Int) -> String {
    switch QuizOptions(rawValue: tag) {
    case .category:
      String(localized: "CATEGORY_TEXT")

    case .difficulty:
      String(localized: "DIFFICULTY_TEXT")

    case .type:
      String(localized: "TYPE_TEXT")

    default:
      ""
    }
  }

  func subtitle(_ tag: Int) -> String {
    switch QuizOptions(rawValue: tag) {
    case .category:
      listCategoryDesc[category]

    case .difficulty:
      listDifficultiesDesc[difficulty]

    case .type:
      listTypeDesc[type]

    default:
      ""
    }
  }

  @objc func increase(sender: UIButton) {
    switch QuizOptions(rawValue: sender.tag) {
    case .category:
      category = category + 1 > (listCategory.count - 1) ? category : category + 1

    case .difficulty:
      difficulty = difficulty + 1 > (listDifficulties.count - 1) ? difficulty : difficulty + 1

    case .type:
      type = type + 1 > (listType.count - 1) ? type : type + 1

    default:
      break
    }
  }

  @objc func decrease(sender: UIButton) {
    switch QuizOptions(rawValue: sender.tag) {
    case .category:
      category = category - 1 < 0 ? 0 : category - 1

    case .difficulty:
      difficulty = difficulty - 1 < 0 ? 0 : difficulty - 1

    case .type:
      type = type - 1 < 0 ? 0 : type - 1

    default:
      break
    }
  }

  @objc func start() {
    Task {
      do {
        isLoading = true

        let response = try await NetworkServices.shared.fetchQuiz(amount: totalQuestions, category: category, difficulty: difficulty , type: type)

        isLoading = false

        switch response.response_code {
        case .success:
          fetchedQuiz = QuizViewModel(questions: response.results)

        case .noResults:
          throw OpenTriviaDatabaseError.noResults

        case .invalidParameter:
          throw OpenTriviaDatabaseError.invalidParameter

        case .tokenNotFound:
          throw OpenTriviaDatabaseError.tokenNotFound

        case .tokenEmpty:
          throw OpenTriviaDatabaseError.tokenEmpty

        case .rateLimit:
          throw OpenTriviaDatabaseError.rateLimit
        }
      } catch {
        errorMessage = error.localizedDescription

        showError = true
        isLoading = false
      }
    }
  }
}

enum QuizOptions: Int, CaseIterable {
  case category, difficulty, type
}
