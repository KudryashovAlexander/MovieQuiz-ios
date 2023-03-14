//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Александр Кудряшов on 14.03.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)  // 2
}
