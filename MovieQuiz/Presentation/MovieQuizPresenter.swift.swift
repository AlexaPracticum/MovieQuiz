import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private var currentQuestionIndex = 0
    let questionsAmount = 10
    private var correctAnswers = 0

    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        let isCorrect = isYes == currentQuestion.correctAnswer
        if isCorrect { correctAnswers += 1 }

        viewController?.highlightImageBorder(isCorrect: isCorrect)
        viewController?.setButtonsEnabled(false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.storeCurrentResult(correct: correctAnswers, total: questionsAmount)

            let currentScore = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let fullText = currentScore + "\n" + statisticService.bestAttemptText

            let resultVM = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: fullText,
                buttonText: "Сыграть ещё раз"
            )

            let alertModel = AlertModel(from: resultVM) { [weak self] in
                self?.restartGame()
            }

            viewController?.showAlert(model: alertModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }

        viewController?.setButtonsEnabled(true)
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
