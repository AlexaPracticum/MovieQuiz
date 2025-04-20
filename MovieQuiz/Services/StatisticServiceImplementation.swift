import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
   
    private let storage: UserDefaults = .standard
   
    private var correctAnswersCount: Int {
        get {
            storage.integer(forKey: "correctAnswersCount")
        }
        set {
            storage.set(newValue, forKey: "correctAnswersCount")
        }
    }
    
    private var totalQuestionCount: Int {
        get {
            storage.integer(forKey: "totalQuestionCount")
        }
        set {
            storage.set(newValue, forKey: "totalQuestionCount")
        }
    }
    
    var averageAccuracy: Double {
        let totalGames = gameCount
        guard totalQuestionCount > 0 else { return 0 }
        let totalCorrect = correctAnswersCount
        return (Double(totalCorrect) / Double(10 * totalGames)) * 100
    }
    
    var gameCount: Int {
        get {
            storage.integer(forKey: "gameCount")
        }
        set {
            storage.set(newValue, forKey: "gameCount")
        }
    }
    
    var bestAttempt: GameResult {
        get {
           let totalQuestions = storage.integer(forKey: "bestTotalQuestions")
           let correctAnswers = storage.integer(forKey: "bestCorrectAnswers")
           let dateFinish = storage.object(forKey: "bestDateFinish") as? Date ?? Date()
            
            return GameResult(
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                dateFinish: dateFinish)
        }
        set {
            storage.set(newValue.totalQuestions, forKey: "bestTotalQuestions")
            storage.set(newValue.correctAnswers, forKey: "bestCorrectAnswers")
            storage.set(newValue.dateFinish, forKey: "bestDateFinish")
        }
    }
    
    func storeCurrentResult(correct count: Int, total amount: Int) {
        gameCount += 1
        correctAnswersCount += count
        totalQuestionCount += amount

        let newResult = GameResult(
            correctAnswers: count,
            totalQuestions: amount,
            dateFinish: Date())
        
        let best = bestAttempt
        let bestAccuracy = best.totalQuestions > 0
            ? Double(best.correctAnswers) / Double(best.totalQuestions)
            : -1
        let newAccuracy = Double(count) / Double(amount)
        
        if newAccuracy > bestAccuracy {
            bestAttempt = newResult
        }
    }
    
}

extension StatisticServiceImplementation {
        var bestAttemptText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        let result = bestAttempt
            
        return """
        Количество сыграных квизов: \(gameCount)
        Рекорд: \(result.correctAnswers)/\(result.totalQuestions) \(dateFormatter.string(from: result.dateFinish))
        Средняя точность: \(String(format: "%.2f", averageAccuracy))%
        """
    }
}
