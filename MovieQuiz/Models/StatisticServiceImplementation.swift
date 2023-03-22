import Foundation
final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    //точность ответов
    var totalAccuracy: Double {
        get{
            if let accuracy = userDefaults.string(forKey: Keys.totalAccuracy.rawValue) {
                if let doubleAccuracy = Double(accuracy){
                    return doubleAccuracy
                }
            }
            print("Невозможно получить totalAccuracy")
            return 0.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
            print("totalAccuracy сохранено")
        }
    }
    //количество игр
    var gamesCount: Int {
        get {
            if let gameCount = userDefaults.string(forKey: Keys.gamesCount.rawValue) {
                if let intGameCount = Int(gameCount){
                    return intGameCount
                }
            }
            print("Невозможно получить gamesCount!")
            return 0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
            print("gamesCount сохранено")
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
            print("bestGame сохранено")
        }
        
    }
    //функция сохранения лучшего результата
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalAccuracy = (self.totalAccuracy * Double((gamesCount - 1)) + Double(count)/Double(amount))/Double(gamesCount)
        let game = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.newValueRecordIsBettter(game){
            bestGame = game
            print("Записано новое значение рекорда")
        }
    }
    
    //Ключи для сохранения в UserDefaults
    //ДОПОЛНИТЕЛЬНО К ЗАДАНИЮ ДОБАВИЛ СОХРАНЕНИЕ ПАРАМЕТРА totalAccuracy. ИНАЧЕ ПРИ ЗАКРЫТИИ ПРИЛОЖЕНИЯ НЕВОЗМОЖНО ОПРЕДЕЛИТЬ ТОЧНОЕ СРЕДНЕЕ ЗНАЧЕНИЕ ПРАВИЛЬНЫХ ОТВЕТОВ ЗА ВСЕ ИГРЫ, ТАК КАК СУММАРНОЕ КОЛИЧЕСТВО ПРАВИЛЬНЫХ ОТВЕТОВ НИГДЕ НЕ СОХРАНЯЕТСЯ. В ЗАДАНИИ ИМЕННО УКАЗАНО ОПРЕДЕЛИТЬ СРЕДНЮЮ ТОЧНОСТЬ ЗА ВСЕ ИГРЫ, ПРОШУ ПРОВЕРИТЬ.
    private enum Keys: String, CodingKey {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
}

