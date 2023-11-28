import Foundation
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
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
