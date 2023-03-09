import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    //Добавил аутлеты кнопок для возможности изменения состояния isEnabled
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    //текущий индекс вопроса
    private var currentQuestionIndex: Int = 0
    //количество правильных ответов
    private var correctAnswers: Int = 0
    //количетсво сыгранных квизов
    private var currentQuizFinish: Int = 0
    
    //точность ответов
    private var accauracyAnswer: Double = 0.0 {
        willSet{
            if newValue > self.accauracyAnswer {
                bestResult = "Рекорд: \(correctAnswers)/\(questions.count) (" + Date().dateTimeString + ")"
            }
        }
    }
    
    //лучший результат
    private var bestResult = String()
    //средняя точность
    private var averageAccuracy: Double = 0.0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showNextQuestions()
    }
    
    // MARK: - Actions
    
    //Кнопка Да
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let giveAnswer = true
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    //Кнопка Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
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
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // заново показываем первый вопрос
            let firstQuestion = questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
            
            // Скидываем текщий индекс массива вопросов до 0
            self.currentQuestionIndex = 0
            
            //Скидываем счетчик правильных ответов до 0
            self.correctAnswers = 0
            
            self.showNextQuestions()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    // Прошли квест или нет
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 {
          
          // прибавляем количество сыгранных квизов
          self.currentQuizFinish += 1
          
          // процент выигранных квизов
          accauracyAnswer = Double(correctAnswers)/Double(questions.count)
          averageAccuracy = (averageAccuracy + accauracyAnswer * 100)/Double(currentQuizFinish)
          let text = "Ваш результат: \(correctAnswers)/10" + "\n" + "Количество сыгранных квизов:\(currentQuizFinish)" + "\n" + "\(bestResult)" + "\n" + "Средняя точность: \(averageAccuracy)%"
          let viewModel = QuizResultsViewModel(
                      title: "Этот раунд окончен!",
                      text: text,
                      buttonText: "Сыграть ещё раз")
                  show(quiz: viewModel)

      } else {
          currentQuestionIndex += 1
          showNextQuestions()
      }
    }
    
    // Показ модели
    private func showNextQuestions(){
        let nextQuestions = questions[currentQuestionIndex]
        let newModel = convert(model: nextQuestions)
        show(quiz: newModel)
    }
}

// массив вопросов и фильмов
private let questions: [QuizQuestion] = [
    QuizQuestion(
        image: "The Godfather",
        correctAnswer: true),
    QuizQuestion(
        image: "The Dark Knight",
        correctAnswer: true),
    QuizQuestion(
        image: "Kill Bill",
        correctAnswer: true),
    QuizQuestion(
        image: "The Avengers",
        correctAnswer: true),
    QuizQuestion(
        image: "Deadpool",
        correctAnswer: true),
    QuizQuestion(
        image: "The Green Knight",
        correctAnswer: true),
    QuizQuestion(
        image: "Old",
        correctAnswer: false),
    QuizQuestion(
        image: "The Ice Age Adventures of Buck Wild",
        correctAnswer: false),
    QuizQuestion(
        image: "Tesla",
        correctAnswer: false),
    QuizQuestion(
        image: "Vivarium",
        correctAnswer: false)
]
