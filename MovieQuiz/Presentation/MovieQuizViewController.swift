import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate{
    //MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var currentQuestionIndex: Int = 0 //текущий индекс вопроса
    private var correctAnswers: Int = 0 //количество правильных ответов
    private let questionsAmount: Int = 10  // Количество вопросов
    
    private var questionFactory: QuestionFactoryProtocol? //Класс базы данных
    private var currentQuestion: QuizQuestion? //текущий вопрос
    
    private var alertFactory: AlertFactoryProtocol? //Модель alerta
    private var statisticServiceImplementation:StatisticService = StatisticServiceImplementation()
    private var bestGame: GameRecord {
        statisticServiceImplementation.bestGame
    }
    
    //точность ответов
    private var accauracyAnswer: Double = 0.0
    private var gamesCount: Int {
        statisticServiceImplementation.gamesCount
    }
    private var bestResult = String() //лучший результат

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    //Кнопка Да
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let giveAnswer = true
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    //Кнопка Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let giveAnswer = false
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    //Передаем картинку, вопрос и номер вопроса в оутлет
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Выводим алерт если закончилось кол-во вопросов
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: {[weak self] in
                guard let self = self else {return}
                self.currentQuestionIndex = 0 // Скидываем текщий индекс массива вопросов до 0
                self.correctAnswers = 0 //Скидываем счетчик правильных ответов до 0
                self.questionFactory?.requestNextQuestion()
        })
        alertFactory = AlertPresenter()
        alertFactory?.showAlert(model: alertModel, viewController: self)
    }
    
    // конвертация базы данных во вью
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image)
        if image == nil {
            errorAlert()
        }
        let imageForView = image ?? UIImage()
        return QuizStepViewModel(
            image: imageForView,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // Вывод ошибки
    private func errorAlert(){
        let viewModel = QuizResultsViewModel(
                    title: "Что-то пошло не так(",
                    text: "Невозможно загрузить данные",
                    buttonText: "Попробовать еще раз")
                show(quiz: viewModel)
        currentQuestionIndex = 0
    }
    
    // Выводим результат
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            self.correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        self.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    // Прошли квест или нет
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          statisticServiceImplementation.store(correct: correctAnswers, total: questionsAmount)
          
          //средняя точность за все игра
          accauracyAnswer = statisticServiceImplementation.totalAccuracy * 100
          bestResult = "Рекорд: \(bestGame.correct)/\(bestGame.total) (" + bestGame.date.dateTimeString + ")"
          
          let text = "Ваш результат: \(correctAnswers)/10" + "\n" + "Количество сыгранных квизов:\(statisticServiceImplementation.gamesCount)" + "\n" + "\(bestResult)" + "\n" + "Средняя точность:\(String(format: "%.2f", accauracyAnswer))%"
          
          let viewModel = QuizResultsViewModel(
                      title: "Этот раунд окончен!",
                      text: text,
                      buttonText: "Сыграть ещё раз")

          show(quiz: viewModel)
 

      } else {
          currentQuestionIndex += 1
          questionFactory?.requestNextQuestion()
      }
    }
}

