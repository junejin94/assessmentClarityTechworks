//
//  MainView.swift
//  Quiz Master
//
//  Created by Phua June Jin on 20/04/2024.
//

import Combine
import UIKit
import SwiftUI

class MainView: UIViewController, ObservableObject {
  private var cancellable = Set<AnyCancellable>()

  private var listTitle: [UILabel] = []
  private var listSubtitle: [UILabel] = []

  private var activityIndicator = UIActivityIndicatorView(style: .large)

  var viewModel: MainViewModel

  private var viewTitle: UIView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalSpacing

    let label = UILabel()
    label.text = "Quiz Master"
    label.font = .boldSystemFont(ofSize: 32)
    label.textColor = .label
    label.sizeToFit()

    let buttonRankings = UIButton()
    buttonRankings.setImage(UIImage(systemName: "trophy.fill"), for: .normal)
    buttonRankings.addTarget(self, action: #selector(showScoreboard), for: .touchUpInside)

    stack.addArrangedSubview(UIButton())
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(buttonRankings)

    return stack
  }

  private var buttonStart: UIView {
    let button = UIButton()
    button.setTitle("Start", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemBlue
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 10
    button.layer.masksToBounds = true
    button.layer.borderColor = UIColor.clear.cgColor
    button.addTarget(viewModel, action: #selector(viewModel.start), for: .touchUpInside)

    return button
  }

  private var viewOptions: [UIView] {
    var arr: [UIView] = []

    for option in QuizOptions.allCases {
      let temp = UIStackView()
      temp.axis = .vertical

      temp.addArrangedSubview(title(option))
      temp.addArrangedSubview(subtitle(option))

      arr.append(temp)
    }

    return arr
  }

  init(viewModel: MainViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    self.viewModel = MainViewModel()

    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initBackground()
    initMain()
    initActivityIndicator()
    initCombine()
  }

  private func initBackground() {
    let label = UIView()

    view.addSubview(label)

    label.backgroundColor = .systemBackground
    label.translatesAutoresizingMaskIntoConstraints = false
    label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }

  private func initMain() {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.distribution = .equalSpacing

    stack.addArrangedSubview(viewTitle)
    stack.addArrangedSubview(UIView())

    for view in viewOptions {
      stack.addArrangedSubview(view)
    }

    stack.addArrangedSubview(UIView())
    stack.addArrangedSubview(buttonStart)

    view.addSubview(stack)

    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16).isActive = true
    stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
  }

  private func initActivityIndicator() {
    activityIndicator.center = view.center
    activityIndicator.frame = view.frame
    activityIndicator.backgroundColor = .gray.withAlphaComponent(0.5)
    activityIndicator.hidesWhenStopped = true

    view.addSubview(activityIndicator)
  }

  private func initCombine() {
    viewModel.$category
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        let tag = QuizOptions.category.rawValue

        self?.listTitle.first(where: { $0.tag == tag })?.text = self?.viewModel.title(tag)
        self?.listSubtitle.first(where: { $0.tag == tag })?.text = self?.viewModel.subtitle(tag)
      }
      .store(in: &cancellable)

    viewModel.$difficulty
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        let tag = QuizOptions.difficulty.rawValue

        self?.listTitle.first(where: { $0.tag == tag })?.text = self?.viewModel.title(tag)
        self?.listSubtitle.first(where: { $0.tag == tag })?.text = self?.viewModel.subtitle(tag)
      }
      .store(in: &cancellable)

    viewModel.$type
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        let tag = QuizOptions.type.rawValue

        self?.listTitle.first(where: { $0.tag == tag })?.text = self?.viewModel.title(tag)
        self?.listSubtitle.first(where: { $0.tag == tag })?.text = self?.viewModel.subtitle(tag)
      }
      .store(in: &cancellable)

    viewModel.$isLoading
      .receive(on: RunLoop.main)
      .sink { [weak self] value in
        if value {
          self?.activityIndicator.startAnimating()
        } else {
          self?.activityIndicator.stopAnimating()
        }
      }
      .store(in: &cancellable)

    viewModel.$fetchedQuiz
      .receive(on: RunLoop.main)
      .sink { viewModel in
        guard let viewModel else { return }

        let view = UIHostingController(rootView: QuizView(viewModel: viewModel).environmentObject(self))

        self.navigationController?.pushViewController(view, animated: true)
      }
      .store(in: &cancellable)

    viewModel.$showError
      .receive(on: RunLoop.main)
      .sink { [weak self] show in
        guard show else { return }

        let alert = UIAlertController(title: String(localized: "TEXT_ERROR"), message: self?.viewModel.errorMessage ?? String(localized: "TEXT_UNKNOWN_ERROR"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "TEXT_OK").uppercased(), style: .default, handler: { _ in
          self?.viewModel.showError = false
        }))

        self?.present(alert, animated: true, completion: nil)
      }
      .store(in: &cancellable)
  }

  private func title(_ option: QuizOptions) -> UIView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalCentering

    let label = UILabel()
    label.tag = option.rawValue

    listTitle.append(label)

    stack.addArrangedSubview(UIView())
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(UIView())

    label.font = .boldSystemFont(ofSize: 21)

    return stack
  }

  private func subtitle(_ option: QuizOptions) -> UIView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalSpacing

    let buttonLeft = UIButton()
    buttonLeft.tag = option.rawValue
    buttonLeft.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    buttonLeft.addTarget(viewModel, action: #selector(viewModel.decrease(sender:)), for: .touchUpInside)

    let buttonRight = UIButton()
    buttonRight.tag = option.rawValue
    buttonRight.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    buttonRight.addTarget(viewModel, action: #selector(viewModel.increase(sender:)), for: .touchUpInside)

    let label = UILabel()
    label.tag = option.rawValue

    listSubtitle.append(label)

    stack.addArrangedSubview(buttonLeft)
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(buttonRight)

    return stack
  }

  @objc private func showScoreboard() {
    present(UIHostingController(rootView: Scoreboard(viewModel: ScoreboardViewModel())), animated: true)
  }
}
