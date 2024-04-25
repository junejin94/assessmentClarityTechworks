//
//  QuizView.swift
//  Quiz Master
//
//  Created by Phua June Jin on 21/04/2024.
//

import SwiftUI

enum ViewState {
  case start
  case loaded
}

struct QuizView: View {
  @EnvironmentObject var parent: MainView

  @State private var state: ViewState = .start
  @State private var name = ""

  @State private var isLoaded = false
  @State private var canSubmit = false
  @State private var showError = false

  @ObservedObject var viewModel: QuizViewModel

  private var viewLoad: some View {
    VStack {
      viewScore
      viewTimer
      viewQuestion

      Spacer()

      viewChoices
    }
    .padding(.horizontal, 12)
  }

  private var viewScore: some View {
    HStack(spacing: 0) {
      Text(String(format: String(localized: "SCORE_CURRENT"), viewModel.totalText))

      if viewModel.isAnswered {
        Text("(")
        Text("\(viewModel.scoreText)")
          .foregroundStyle(viewModel.isCorrect ? .green : .red)
        Text(")")
      }
    }
    .font(.headline)
    .padding(.bottom, 8)
  }

  private var viewTimer: some View {
    QuizTimer(granularity: viewModel.granularity, publisher: viewModel.$progress.eraseToAnyPublisher())
      .frame(height: 16)
      .padding([.bottom, .horizontal], 8)
  }

  private var viewQuestion: some View {
    Text(viewModel.questionText)
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
  }

  private var viewChoices: some View {
    Group {
      ForEach(viewModel.choices, id: \.self) { choice in
        choiceView(choice)
          .padding(.bottom, 6)
      }
    }
    .padding(.bottom, 8)
  }

  private func choiceView(_ string: String) -> some View {
    Button {
      viewModel.answered(string)
    } label: {
      Text(string)
        .frame(maxWidth: .infinity)
        .padding(10)
        .font(.subheadline.weight(.medium))
        .border(viewModel.colors[string] ?? .blue, width: 2)
    }
    .buttonStyle(.plain)
    .disabled(viewModel.isAnswered)
  }

  var body: some View {
    switch state {
    case .start:
      GeometryReader { geo in
        CountDown(isLoaded: $isLoaded)
          .onAppear {
            viewModel.load()
          }
          .onChange(of: isLoaded) {
            if isLoaded { state = .loaded }
          }
          .frame(width: geo.size.width, height: geo.size.height)
          .ignoresSafeArea()
      }

    case .loaded:
      viewLoad
        .navigationTitle(String(format: String(localized: "TITLE_QUESTIONS"), viewModel.index + 1, viewModel.questions.count))
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              viewModel.next()
            } label: {
              Text("Next ") + Text(Image(systemName: "chevron.right")).bold()
            }
            .disabled(!viewModel.isAnswered || viewModel.hasEnded)
          }
        }.onAppear {
          viewModel.startTimer()
        }.onChange(of: viewModel.hasEnded) {
          canSubmit = viewModel.hasEnded && viewModel.canSubmit
        }.onChange(of: viewModel.showHighscore) {
          if viewModel.showHighscore {
            parent.present(UIHostingController(rootView: Scoreboard(viewModel: ScoreboardViewModel())), animated: true)
          }
        }.onChange(of: viewModel.showError) {
          showError = viewModel.showError
        }.alert(isPresented: $showError) {
          Alert(title: Text("TEXT_ERROR"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("TEXT_OK")))
        }.alert("TEXT_HIGH_SCORE", isPresented: $canSubmit, actions: {
          TextField("", text: $name)
            .onChange(of: name, { old, new in
              name = new.count > 3 ? old.uppercased() : new.uppercased()
            })

          Button(String(localized: "TEXT_SUBMIT")) {
            viewModel.submit(name)
          }.disabled(name.count < 3)
        }, message: {
          Text("TEXT_ENTER_YOUR_INITIAL")
        })
    }
  }
}

#Preview {
  QuizView(viewModel: QuizViewModel(questions: [QuizModel(type: "any", difficulty: "easy", category: "", question: "", correct_answer: "1", incorrect_answers: ["2", "3", "4"])]))
}
