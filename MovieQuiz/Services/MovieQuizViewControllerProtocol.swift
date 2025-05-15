import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showAlert()
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setButtonsEnabled(_ isEnabled: Bool)
}
