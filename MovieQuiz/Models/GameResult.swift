import Foundation

struct GameResult {
    var correctAnswers: Int
    var totalQuestions: Int
    var dateFinish: Date
    
    func gameComparison(_ another: GameResult) -> Bool {
        if correctAnswers > another.correctAnswers {
            return true
        } else if correctAnswers < another.correctAnswers {
            return false
        } else {
            return dateFinish > another.dateFinish
        }
    }
}
