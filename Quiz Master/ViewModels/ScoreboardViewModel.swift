//
//  ScoreboardViewModel.swift
//  Quiz Master
//
//  Created by Phua June Jin on 23/04/2024.
//

import Foundation

class ScoreboardViewModel: ObservableObject {
  @Published var scores: [Scores] = []

  func fetchScores() {
    do {
      scores = try Database.shared.getScore()
    } catch {
      print(error)
    }
  }
}
