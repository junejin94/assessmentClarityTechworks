//
//  CountDown.swift
//  Quiz Master
//
//  Created by Phua June Jin on 21/04/2024.
//

import SwiftUI

struct CountDown: View {
  @Binding var isLoaded: Bool

  @State private var counter = 3
  @State private var scale = true

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    if counter > 0 {
      Text("\(counter)")
        .font(.system(size: 75, weight: .bold))
        .scaleEffect(scale ? 2 : 1)
        .navigationBarBackButtonHidden()
        .onReceive(timer) { time in
          counter -= 1

          if counter < 1 {
            isLoaded = true

            timer.upstream.connect().cancel()
          }

          withAnimation(.bouncy(duration: 0.5)) {
            scale.toggle()
          } completion: {
            withAnimation(.bouncy(duration: 0.5)) {
              scale.toggle()
            }
          }
        }
    }
  }
}

#Preview {
  CountDown(isLoaded: .constant(false))
}
