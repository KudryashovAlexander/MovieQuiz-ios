import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {

    
    
    //MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0 //текущий индекс вопроса
    private var correctAnswers: Int = 0 //количество правильных ответов
    private let questionsAmount: Int = 10  // Количество вопросов
    
    private var questionFactory: QuestionFactoryProtocol? //Класс базы данных
    private var currentQuestion: QuizQuestion? //текущий вопрос
    
    private var alertPresenter: AlertFactoryProtocol? = AlertPresenter()//Модель alerta
    private var statisticService:StatisticService = StatisticServiceImplementation()
    private var bestGame: GameRecord {
        statisticService.bestGame
    }
    
    //точность ответов
    private var accauracyAnswer: Double = 0.0
    private var gamesCount: Int {
        statisticService.gamesCount
    }
    private var bestResult = String() //лучший результат

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
       imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
//        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        questionFactory?.loadData()
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
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    } 
    

    func didFailToLoadData(with error: Error) {
        print(error.localizedDescription)
    showNetworkError(message: "Ошибка с Интернет соединением") // возьмём в качестве сообщения описание ошибки
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
        alertPresenter?.showAlert(model: alertModel, viewController: self)
    }
    
    // конвертация базы данных во вью
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        let imageForView = image ?? UIImage()
        return QuizStepViewModel(
            image: imageForView,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // Выводим результат
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            self.correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        self.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        self.reverseEnabledButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.reverseEnabledButton()
        }
    }
    
    //Функция отключения кнопок
    private func reverseEnabledButton(){
        self.yesButton.isEnabled = !yesButton.isEnabled
        self.noButton.isEnabled = !noButton.isEnabled
    }
    
    // Прошли квест или нет
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          statisticService.store(correct: correctAnswers, total: questionsAmount)
          
          //средняя точность за все игры
          accauracyAnswer = statisticService.totalAccuracy * 100
          bestResult = "Рекорд: \(bestGame.correct)/\(bestGame.total) (" + bestGame.date.dateTimeString + ")"
          
          let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов:\(statisticService.gamesCount)
            \(bestResult)
            Средняя точность:\(String(format: "%.2f", accauracyAnswer))%
            """
          
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
    //метод начинающий индикатор
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    //метод заканчивающий индикатор
    private func hideLoadingIndicator()  {
        activityIndicator.isHidden = true// говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // заканчиваем анимацию
    }
    
    //Ошибка, выводим алерт
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
            self.questionFactory?.loadData()
            }
            
        alertPresenter?.showAlert(model: model, viewController: self)
    }
    
}

