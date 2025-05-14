import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Properties
    private var currentQuestionIndex: Int = .zero
    let questionsAmount: Int = 10
    var correctAnswers: Int = .zero
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private var alertPresenter: AlertPresenter?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        self.questionFactory?.loadData()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.storeCurrentResult(
                correct: correctAnswers,
                total: self.questionsAmount)
            
            let currentScore = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
            let fullText = currentScore + "\n" + statisticService.bestAttemptText
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: fullText,
                buttonText: "Сыграть ещё раз"
            )
            guard let viewController = viewController else { return }
            alertPresenter?.showAlert(quiz: viewModel, on: viewController as! UIViewController)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        
        viewController?.setButtonsEnabled(true)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        
        viewController?.setButtonsEnabled(false)
    }
    
    func showAlert() {
        self.restartGame()
        
        viewController?.setButtonsEnabled(true)

        
        if self.questionFactory?.requestNextQuestion() != nil {
            let viewModel = convert(model: currentQuestion!)
            
            viewController?.show(quiz: viewModel)
        }
    }
    
}
