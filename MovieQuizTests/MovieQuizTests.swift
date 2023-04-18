//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Александр Кудряшов on 11.04.2023.
//

import XCTest


struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler:@escaping(Int)-> Void) {
        DispatchQueue.main.asyncAfter (deadline: .now() + 1.0) {
            handler (num1 + num2)
        }
        
    }
    
    func subtraction(num1: Int, num2: Int,handler:@escaping(Int)-> Void ){
        DispatchQueue.main.asyncAfter (deadline: .now() + 1.0) {
            handler (num1 - num2)
        }
        
    }
    
    func multiplication(num1: Int, num2: Int, handler:@escaping(Int)-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            handler (num1 * num2)
        }
    }
}

final class MovieQuizTests: XCTestCase {

    func testAddition() throws {
        //Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let nem2 = 2
        
        //When
        let expectation = expectation(description: "Addition function expectation")
        let result = arithmeticOperations.addition(num1: 1, num2: 2) { result in
            //Then
            XCTAssertEqual(result,3)
            expectation.fulfill() //Ожидание было выполнено
        }
        waitForExpectations(timeout: 2)//надо подождать 2 секунды
        
    }
}
