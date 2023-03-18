import UIKit
class AlertPresenter: AlertFactoryProtocol {
    
    func showAlert(model: AlertModel, viewController: UIViewController) {
    let alert = UIAlertController(title: model.title,
                                  message: model.message,
                                  preferredStyle: .alert)

    let action = UIAlertAction(title: model.buttonText, style: .default) {  _ in
        //guard self != nil else {return}
        model.completion()
    }
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}
}
