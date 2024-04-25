//
//  QuizTimer.swift
//  Quiz Master
//
//  Created by Phua June Jin on 21/04/2024.
//

import Combine
import SwiftUI

struct QuizTimer: View {
  @State private var progress: Double = 1.0

  var granularity: Double = 0.01
  var publisher: AnyPublisher<Double, Never>?

  var body: some View {
    GeometryReader { geo in
      HStack {
        ProgressView(value: progress)
          .onReceive(publisher ?? Empty<Double, Never>().eraseToAnyPublisher(), perform: { value in
            progress = value
          })
          .frame(width: geo.size.width * 0.85)

        Text(String(format: "%.1f s", progress * 10))
          .frame(width: geo.size.width * 0.15)
      }
    }
  }
}

#Preview {
  QuizTimer()
}
