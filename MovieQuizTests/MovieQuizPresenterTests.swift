import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    var alertShown = false
    var quizStepShown: QuizStepViewModel?
    var quizResultShown: QuizResultsViewModel?
    var borderHighlighted: Bool?
    var loadingIndicatorShown = false
    var networkErrorMessage: String?
    var setButtonsIsEnabled: Bool?

    func showAlert() {
        alertShown = true
    }
    
    func showAlert(model: MovieQuiz.AlertModel) {
        alertShown = true
    }

    func show(quiz step: QuizStepViewModel) {
        quizStepShown = step
    }

    func show(quiz result: QuizResultsViewModel) {
        quizResultShown = result
    }

    func highlightImageBorder(isCorrect: Bool) {
        borderHighlighted = isCorrect
    }

    func showLoadingIndicator() {
        loadingIndicatorShown = true
    }

    func hideLoadingIndicator() {
        loadingIndicatorShown = false
    }

    func showNetworkError(message: String) {
        networkErrorMessage = message
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        setButtonsIsEnabled = isEnabled
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(imageName: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
