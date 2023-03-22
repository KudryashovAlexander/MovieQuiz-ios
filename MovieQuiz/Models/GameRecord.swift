import Foundation
struct GameRecord: Codable {
    let correct: Int //количество правильных ответов
    let total: Int //количество вопросов
    let date: Date //Дата прохождения квиза
    
    //функция проверки нового значения со старым
    func newValueRecordIsBettter(_ newRecord: GameRecord) -> Bool {
        print("Сработала проверка сторе")
        return correct < newRecord.correct
    }
}
