import Foundation
struct GameRecord: Codable {
    let correct: Int //количество правильных ответов
    let total: Int //количество вопросов
    let date: Date //Дата прохождения квиза
    
    //функция проверки нового значения со старым
    func newValueRecordIsBettter(_ newRecord: GameRecord) -> Bool {
        if total == 0 || newRecord.total == 0 {
            return false
        }
        if Double(correct)/Double(total) < Double(newRecord.correct)/Double(newRecord.total) {
            return true
        }
        return false
    }
}
