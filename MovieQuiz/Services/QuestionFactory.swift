import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading //отвечает за загрузку из сети
    private weak var delegate: QuestionFactoryDelegate? //Для использования методов в QuestionFactoryDelegate, то есть в MovieQuizController
    
    private var movies: [MostPopularMovie] = [] //Массив для сохранения фильмов (250 штук)

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    //Метод загрузки массива данных
    func loadData() {
            moviesLoader.loadMovies { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                        self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                    }
                }
            }
        }
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            correctAnswer: false)
//    ]
    

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
                print("Failed to load image")
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            // NOTE: Добавлено изменение рейтинга в вопросе
            let nextRaiting = (6...9).randomElement() ?? 0
            
            let text = "Рейтинг этого фильма больше чем \(nextRaiting)?"
            let correctAnswer = rating > Float(nextRaiting)
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

}
