import UIKit

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(quiz result: QuizResultsViewModel, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { [weak self] _ in
            self?.delegate?.showAlert()
        }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(model: AlertModel, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
