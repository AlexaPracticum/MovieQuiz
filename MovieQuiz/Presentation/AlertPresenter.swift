import UIKit

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    weak var viewController: UIViewController?

    init(delegate: AlertPresenterDelegate? = nil, viewController: UIViewController) {
        self.delegate = delegate
        self.viewController = viewController
    }

    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Game results"
        viewController?.present(alert, animated: true)
    }
}
