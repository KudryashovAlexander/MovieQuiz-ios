import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRage() throws { // тест на успешное взятие элемента по индексу
        //Give
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 2]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value,2)
    }
    
    func testGetValueOutOfRange() throws {// тест на взятие элемента по неправильному индексу
        //Give
        let array = [1, 1, 2, 3, 5]
        //When
        let value = array[safe: 20]
        //Then
        XCTAssertNil(value)
    }
}
