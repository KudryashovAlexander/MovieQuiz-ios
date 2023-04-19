//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Кудряшов on 18.04.2023.
//

import UIKit
final class MovieQuizPresenter {
    let questionsAmount: Int = 10  // Количество вопросов
    private var currentQuestionIndex: Int = 0 //текущий индекс вопроса
    var currentQuestion: QuizQuestion? //текущий вопрос
    weak var viewController: MovieQuizViewController?
    
    var correctAnswers: Int = 0 //количество правильных ответов
    
    var questionFactory: QuestionFactoryProtocol?
    var statisticService:StatisticService = StatisticServiceImplementation()
    var bestGame: GameRecord {
        statisticService.bestGame
    }
    
    //точность ответов
    private var accauracyAnswer: Double = 0.0
    //Количество игр
    private var gamesCount: Int {
        statisticService.gamesCount
    }
    //Лучший результат
    private var bestResult = String()

    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        let imageForView = image ?? UIImage()
        return QuizStepViewModel(
            image: imageForView,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        questionsAmount - 1 == currentQuestionIndex
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //Кнопка Да
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    //Кнопка нет
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes:Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // Прошли квест или нет
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            //TODO: - Не работает извлечение bestGame correct и total
            print("\(self.correctAnswers), \(self.questionsAmount)")
            self.statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
          //средняя точность за все игры
          accauracyAnswer = statisticService.totalAccuracy * 100
          bestResult = "Рекорд: \(bestGame.correct)/\(bestGame.total) (" + bestGame.date.dateTimeString + ")"
          
          let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов:\(statisticService.gamesCount)
            \(bestResult)
            Средняя точность:\(String(format: "%.2f", accauracyAnswer))%
            """
          
          let viewModel = QuizResultsViewModel(
                      title: "Этот раунд окончен!",
                      text: text,
                      buttonText: "Сыграть ещё раз")

            viewController?.show(quiz: viewModel)
 

      } else {
          self.switchToNextQuestion()
          viewController?.showLoadingIndicator() //включаем крутилку
          questionFactory?.requestNextQuestion()
          viewController?.hideLoadingIndicator() //отключаем крутилку
      }
    }
    
    
}

