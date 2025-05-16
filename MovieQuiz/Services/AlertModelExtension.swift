import Foundation

extension AlertModel {
    init(from quizResult: QuizResultsViewModel, completion: @escaping () -> Void) {
        self.title = quizResult.title
        self.message = quizResult.text
        self.buttonText = quizResult.buttonText
        self.completion = completion
    }
}
