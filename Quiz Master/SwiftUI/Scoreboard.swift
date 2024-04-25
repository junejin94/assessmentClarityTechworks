//
//  Scoreboard.swift
//  Quiz Master
//
//  Created by Phua June Jin on 23/04/2024.
//

import SwiftUI

struct Scoreboard: View {
  @ObservedObject var viewModel: ScoreboardViewModel

  var body: some View {
    VStack {
      title
      scoreList

      Spacer()
    }
    .frame(alignment: .topLeading)
    .padding()
    .onAppear {
      viewModel.fetchScores()
    }
  }

  private var title: some View {
    Text("TEXT_HIGH_SCORE")
      .font(.largeTitle.bold())
      .padding(.bottom, 16)
  }

  private var header: some View {
    GridRow {
      Text("HEADER_RANKING")

      Spacer()

      Text("HEADER_INITIALS")

      Spacer()

      Text("HEADER_SCORES")
    }
    .font(.callout.bold())
    .fixedSize(horizontal: false, vertical: true)
  }

  private var scoreList: some View {
    Grid(verticalSpacing: 8) {
      header

      listScore
    }
    .padding(16)
  }

  private var listScore: some View {
    ForEach(Array(zip(viewModel.scores.indices.map({ $0 + 1 }), viewModel.scores)), id: \.0) { idx, item in
      individualScore(rank: idx, initials: item.initials?.uppercased() ?? "---", score: item.score)
    }
  }

  private func individualScore(rank: Int, initials: String, score: Int64) -> some View {
    GridRow {
      Text(String(rank))
      Spacer()
      Text(initials)
      Spacer()
      Text("\(score)")
    }
    .font(.callout)
    .fixedSize()
  }
}

#Preview {
  Scoreboard(viewModel: ScoreboardViewModel())
}
