protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
//Протокол для Делегата (ViewController), чтобы на нем был реализован метод
