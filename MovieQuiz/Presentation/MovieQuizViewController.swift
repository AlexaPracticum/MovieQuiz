
import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(delegate: self)
        questionFactory.requestNextQuestion()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func showAlert() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        
        if (self.questionFactory?.requestNextQuestion()) != nil {
            let viewModel = self.convert(model: self.currentQuestion!)
            
            self.show(quiz: viewModel)
        }
        
    }
    
    // MARK: - IB Actions
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // 4
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.storeCurrentResult(correct: correctAnswers, total: questionsAmount)
            
            let currentScore = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let fullText = currentScore + "\n" + statisticService.bestAttemptText
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: fullText,
                buttonText: "Сыграть ещё раз"
            )
            alertPresenter?.showAlert(quiz: viewModel, on: self)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
    
}
