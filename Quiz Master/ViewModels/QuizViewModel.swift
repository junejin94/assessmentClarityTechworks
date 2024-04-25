//
//  QuizViewModel.swift
//  Quiz Master
//
//  Created by Phua June Jin on 21/04/2024.
//

import Combine
import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
  private var timer: AnyCancellable?

  private let listBool = [String(localized: "BOOL_TRUE"), String(localized: "BOOL_FALSE")]

  private var loadedMC: Bool = false
  private var choicesMC: [String] = []

  private var total = 0
  private var score = 0

  var index = 0
  var questions: [QuizModel]
  var errorMessage: String = ""

  @Published var progress = 1.0

  @Published var hasEnded = false

  @Published var isCorrect = true
  @Published var isAnswered = false

  @Published var totalText = "0"
  @Published var scoreText = "0"

  @Published var question: QuizModel?
  @Published var questionText = ""

  @Published var choices: [String] = []
  @Published var colors: [String: Color] = [:]

  @Published var showError = false
  @Published var showHighscore = false

  let granularity = 0.01

  private var currentType: QuizType? {
    QuizType(rawValue: question?.type)
  }

  private var currentDifficulty: QuizDifficulty? {
    QuizDifficulty(rawValue: question?.difficulty)
  }

  private var currentMultiplier: Double {
    var base = 1.0 * (1 + progress)

    if let mType = currentType?.multiplier {
      base *= mType
    }

    if let mDifficulty = currentDifficulty?.multiplier {
      base *= mDifficulty
    }

    return base
  }

  private var currentMC: [String] {
    if !loadedMC, let question {
      loadedMC = true
      choicesMC = (question.incorrect_answers.map({ $0.htmlDecoded }) + [question.correct_answer.htmlDecoded]).shuffled()
    }

    return choicesMC
  }

  var canSubmit: Bool {
    do {
      let scores = try Database.shared.getScore()

      if scores.count < 10 {
        return true
      } else {
        let scoreLast = try Database.shared.getLastRankingScore()

        return total > scoreLast
      }
    } catch {
      errorMessage = error.localizedDescription

      showError = true

      return true
    }
  }

  func load() {
    progress = 1.0
    question = questions.isEmpty || index >= questions.count ? nil : questions[index]
    questionText = question?.question.htmlDecoded ?? ""

    if let question {
      choices =
      switch QuizType(rawValue: question.type) {
      case .boolean:
        listBool

      case .multiple:
        currentMC

      default:
        []
      }

      colors.removeAll()

      for choice in choices {
        colors[choice.htmlDecoded] = .blue
      }
    }
  }

  func answered(_ answer: String) {
    isCorrect = answer.htmlDecoded.caseInsensitiveCompare(question?.correct_answer.htmlDecoded ?? "") == .orderedSame

    if isCorrect {
      score = Int((100 * currentMultiplier))
      total += score
    } else {
      score = -100
      total = total - 100 < 0 ? 0 : total - 100
    }

    totalText = String(total)
    scoreText = String(score > 0 ? "+" : "") + String(score)

    colors.removeAll()

    for choice in choices {
      colors[choice.htmlDecoded] = choice.htmlDecoded.caseInsensitiveCompare(question?.correct_answer.htmlDecoded ?? "") == .orderedSame ? .green : .red
    }

    isAnswered = true

    if index == questions.count - 1 {
      hasEnded = true
    }
  }

  func startTimer() {
    timer = Timer.publish(every: (granularity * 10), on: .main, in: .default)
      .autoconnect()
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        guard let self else { return }

        if isAnswered {
          timer = nil
        } else if progress - granularity > 0 {
          progress -= granularity
        } else {
          progress = 0

          timer = nil
          answered("")
        }
      }
  }

  func submit(_ name: String) {
    do {
      let scores = try Database.shared.getScore()

      if scores.count < 10 {
        try Database.shared.saveScore(score: Int64(total), initials: name)
      } else if let last = scores.last {
        try Database.shared.delete(last)
        try Database.shared.saveScore(score: Int64(total), initials: name)
      }

      showHighscore = true
    } catch {
      errorMessage = error.localizedDescription

      showError = true
    }
  }

  @objc func next() {
    loadedMC = false
    isAnswered = false

    index += 1

    load()
    startTimer()
  }

  init(questions: [QuizModel]) {
    self.questions = questions
  }
}
