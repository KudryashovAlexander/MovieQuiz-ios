import UIKit
class AlertPresenter {
    
    func showAlert(model: AlertModel, viewController: UIViewController, action: @escaping ()-> Void) {
    let alert = UIAlertController(title: model.title,
                                  message: model.message,
                                  preferredStyle: .alert)

    let action = UIAlertAction(title: model.buttonText, style: .default) {  _ in
        //guard self != nil else {return}
        // заново показываем первый вопрос
        model.completion(action)
    }
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}
}
