//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Кудряшов on 12.04.2023.
//

import XCTest //Импортируем фреймворк
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication! //Примитив. То есть эта переменная символизирует приложение, которое мы тестируем.
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication() // Чтобы быть уверенными, что эта переменная будет проинициализирована на момент использования, присвоим ей значение в методе setUpWithError()
        app.launch()//откроет приложение

        continueAfterFailure = false //Если один тест не прошел, то остальные тесты запускаться не будут
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate() //закроет приложение
        
        app = nil // обнуляющее значение

    }

    

    func testExample() throws {

    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] //Находим первый постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
//        XCTAssertTrue(firstPoster.exists) //Проверяем появлеине первого постера
        
        app.buttons["Yes"].tap() //Находим кнопку Да и нажимаем на ее
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"] // Находим номер вопроса

        let secondPoster = app.images["Poster"] //Находим постер еще раз
        let secondPosterData = secondPoster.screenshot().pngRepresentation
//        XCTAssertTrue(secondPoster.exists) //Проверяем появление второго постера
                
        XCTAssertNotEqual(firstPosterData, secondPosterData) //Проверяем, что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10") //Проверяем, номер второго вопроса 2/10

    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] //Находим первый постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
//        XCTAssertTrue(firstPoster.exists) //Проверяем появлеине первого постера
        
        app.buttons["No"].tap() //Находим кнопку Да и нажимаем на ее
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"] // Находим номер вопроса

        let secondPoster = app.images["Poster"] //Находим постер еще раз
        let secondPosterData = secondPoster.screenshot().pngRepresentation
//        XCTAssertTrue(secondPoster.exists) //Проверяем появление второго постера
                
        XCTAssertNotEqual(firstPosterData, secondPosterData) //Проверяем, что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10") //Проверяем, номер вопроса разный

    }
    
    func testAlert() {
        sleep(2)
        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alertPoster = app.alerts["Game results"]
        XCTAssertTrue(alertPoster.exists) // проверить существование алерта
        XCTAssertEqual(alertPoster.buttons.firstMatch.label, "Сыграть ещё раз")
        
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
