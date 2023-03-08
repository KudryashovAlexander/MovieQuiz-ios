struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
    private let question: String = "Рейтинг этого фильма больше чем 6?"
    
    init (image:String, text:String, correctAnswer:Bool) {
        self.image = image
        self.text = text
        self.correctAnswer = correctAnswer
    }
    init (image: String, correctAnswer: Bool) {
        self.image = image
        self.text = question
        self.correctAnswer = correctAnswer
    }
    
}
