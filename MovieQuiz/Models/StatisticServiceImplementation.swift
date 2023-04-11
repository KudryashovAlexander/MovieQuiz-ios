import Foundation
final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    //точность ответов
    var totalAccuracy: Double {
        get{
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    //количество игр
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }

    }
    // лучшая игра
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат bestGame")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    //функция сохранения лучшего результата
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        if amount != 0 {
            totalAccuracy = (self.totalAccuracy * Double((gamesCount - 1)) + Double(count)/Double(amount))/Double(gamesCount)
        }
        let game = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.newValueRecordIsBettter(game){
            bestGame = game
        }
    }
    
    //Ключи для сохранения в UserDefaults
    private enum Keys: String, CodingKey {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
}

