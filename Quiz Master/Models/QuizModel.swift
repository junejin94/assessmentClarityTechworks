//
//  QuizModel.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Foundation

struct QuizResponse: Codable {
  var response_code: QuizResponseCode
  var results: [QuizModel]
}

struct QuizModel: Codable {
  var type: String
  var difficulty: String
  var category: String
  var question: String
  var correct_answer: String
  var incorrect_answers: [String]
}
