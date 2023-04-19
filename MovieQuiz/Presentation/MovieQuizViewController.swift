import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {

    
    
    //MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0 //количество правильных ответов
    
    
    private var questionFactory: QuestionFactoryProtocol? //Класс базы данных
    
    private var presenter = MovieQuizPresenter()
    private var alertPresenter: AlertFactoryProtocol? = AlertPresenter()//Модель alerta    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        
        activityIndicator.hidesWhenStopped = true
    }
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
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
        presenter.yesButtonClicked()
    }
    
    //Кнопка Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    //Передаем картинку, вопрос и номер вопроса в оутлет
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Выводим алерт если закончилось кол-во вопросов
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: {[weak self] in
                guard let self = self else {return}
            self.presenter.resetQuestionIndex() // Скидываем текщий индекс массива вопросов до 0
            self.correctAnswers = 0 //Скидываем счетчик правильных ответов до 0
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.showAlert(model: alertModel, viewController: self)
    }
    
    // Выводим результат
    func showAnswerResult(isCorrect: Bool) {
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
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.reverseEnabledButton()
        }
    }
    
    //Функция отключения кнопок
    private func reverseEnabledButton(){
        self.yesButton.isEnabled = !yesButton.isEnabled
        self.noButton.isEnabled = !noButton.isEnabled
    }

    //метод начинающий индикатор
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    //метод заканчивающий индикатор
    func hideLoadingIndicator()  {
        activityIndicator.stopAnimating() // заканчиваем анимацию
    }
    
    //Ошибка, выводим алерт
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            }
            
        alertPresenter?.showAlert(model: model, viewController: self)
    }
    
}

