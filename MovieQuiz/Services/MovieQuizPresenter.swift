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
    var statisticService:StatisticService!
    var bestGame: GameRecord {
        statisticService.bestGame
    }

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    // Прошли квест или нет
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = makeResultsMessage()
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
    
    func makeResultsMessage() -> String {
        self.statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
        let bestGame = statisticService.bestGame
        let accauracyAnswer = statisticService.totalAccuracy * 100
        let bestResult = "Рекорд: \(bestGame.correct)/\(bestGame.total) (" + bestGame.date.dateTimeString + ")"
      
      let text = """
        Ваш результат: \(correctAnswers)/10
        Количество сыгранных квизов:\(statisticService.gamesCount)
        \(bestResult)
        Средняя точность:\(String(format: "%.2f", accauracyAnswer))%
        """
        return text
    }
    
    func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.reverseEnabledButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.viewController?.imageBorderZero()
            self.showNextQuestionOrResults()
            self.viewController?.reverseEnabledButton()
        }
    }
    
    
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    

    func didFailToLoadData(with error: Error) {
        print(error.localizedDescription)
        viewController?.showNetworkError(message: "Ошибка с Интернет соединением")
    }
}
