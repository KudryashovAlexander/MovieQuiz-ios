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
        guard let currentQuestion = currentQuestion else { return }
        let giveAnswer = true
        viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    //Кнопка нет
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let giveAnswer = false
        viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    
}

