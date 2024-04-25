//
//  Enum.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Foundation

/// Open Trivia Database Response Code
enum QuizResponseCode: Int, Codable {
  case success
  case noResults
  case invalidParameter
  case tokenNotFound
  case tokenEmpty
  case rateLimit
}

/// Open Trivia Database Category
/// The order is sensitive as it's index is corresponsive to category code
enum QuizCategory: String, CaseIterable {
  case anyCategory
  case generalKnowledge
  case entertainmentBooks
  case entertainmentFilm
  case entertainmentMusic
  case entertainmentMusicalsTheatres
  case entertainmentTelevision
  case entertainmentVideoGames
  case entertainmentBoardGames
  case scienceNature
  case scienceComputers
  case scienceMathematics
  case mythology
  case sports
  case geography
  case history
  case politics
  case art
  case celebrities
  case animals
  case vehicles
  case entertainmentComics
  case scienceGadgets
  case entertainmentJapaneseAnimeManga
  case entertainmentCartoonAnimations

  var description: String {
    switch self {
    case .anyCategory:
      String(localized: "CATEGORY_ANY")

    case .generalKnowledge:
      String(localized: "CATEGORY_GENERAL_KNOWLEDGE")

    case .entertainmentBooks:
      String(localized: "CATEGORY_ENTERTAINMENT_BOOKS")

    case .entertainmentFilm:
      String(localized: "CATEGORY_ENTERTAINMENT_FILM")

    case .entertainmentMusic:
      String(localized: "CATEGORY_ENTERTAINMENT_MUSIC")

    case .entertainmentMusicalsTheatres:
      String(localized: "CATEGORY_ENTERTAINMENT_MUSICALS_THEATRES")

    case .entertainmentTelevision:
      String(localized: "CATEGORY_ENTERTAINMENT_TELEVISION")

    case .entertainmentVideoGames:
      String(localized: "CATEGORY_ENTERTAINMENT_VIDEO_GAMES")

    case .entertainmentBoardGames:
      String(localized: "CATEGORY_ENTERTAINMENT_BOARD_GAMES")

    case .entertainmentComics:
      String(localized: "CATEGORY_ENTERTAINMENT_COMICS")

    case .entertainmentJapaneseAnimeManga:
      String(localized: "CATEGORY_ENTERTAINMENT_JAPANESE_ANIME_MANGA")

    case .entertainmentCartoonAnimations:
      String(localized: "CATEGORY_ENTERTAINMENT_CARTOON_ANIMATIONS")

    case .scienceNature:
      String(localized: "CATEGORY_SCIENCE_NATURE")

    case .scienceComputers:
      String(localized: "CATEGORY_SCIENCE_COMPUTERS")

    case .scienceMathematics:
      String(localized: "CATEGORY_SCIENCE_MATHEMATICS")

    case .scienceGadgets:
      String(localized: "CATEGORY_SCIENCE_GADGETS")

    case .mythology:
      String(localized: "CATEGORY_MYTHOLOGY")

    case .sports:
      String(localized: "CATEGORY_SPORTS")

    case .geography:
      String(localized: "CATEGORY_GEOGRAPHY")

    case .history:
      String(localized: "CATEGORY_HISTORY")

    case .politics:
      String(localized: "CATEGORY_POLITICS")

    case .art:
      String(localized: "CATEGORY_ART")

    case .celebrities:
      String(localized: "CATEGORY_CELEBRITIES")

    case .animals:
      String(localized: "CATEGORY_ANIMALS")

    case .vehicles:
      String(localized: "CATEGORY_VEHICLES")
    }
  }
}

/// Open Trivia Database Difficulty
enum QuizDifficulty: String, CaseIterable {
  case any
  case easy
  case medium
  case hard

  init?(rawValue: String?) {
    switch rawValue {
    case String(localized: "TEXT_EASY"):
      self = .easy

    case String(localized: "TEXT_MEDIUM"):
      self = .medium

    case String(localized: "TEXT_MEDIUM"):
      self = .hard

    default:
      return nil
    }
  }

  var description: String {
    switch self {
    case .any:
      String(localized: "DIFFICULTY_ANY")

    case .easy:
      String(format: String(localized: "DIFFICULTY_EASY"), multiplier)

    case .medium:
      String(format: String(localized: "DIFFICULTY_MEDIUM"), multiplier)

    case .hard:
      String(format: String(localized: "DIFFICULTY_HARD"), multiplier)
    }
  }

  var multiplier: Double {
    switch self {
    case .easy:
      1.00

    case .medium:
      1.25

    case .hard:
      1.50

    default:
      1.00
    }
  }
}

/// Open Trivia Database Type
enum QuizType: String, CaseIterable {
  case any
  case boolean
  case multiple

  init?(rawValue: String?) {
    switch rawValue {
    case String(localized: "TEXT_BOOLEAN"):
      self = .boolean

    case String(localized: "TEXT_MULTIPLE"):
      self = .multiple

    default:
      return nil
    }
  }

  var description: String {
    switch self {
    case .any:
      String(localized: "TYPE_ANY")

    case .boolean:
      String(format: String(localized: "TYPE_TRUE_FALSE"), multiplier)

    case .multiple:
      String(format: String(localized: "TYPE_MULTIPLE_CHOICE"), multiplier)
    }
  }

  var multiplier: Double {
    switch self {
    case .boolean:
      1.00

    case .multiple:
      1.25

    default:
      1.00
    }
  }
}
