import Foundation


protocol StatisticServiceProtocol {
    
    var gameCount: Int {get}
    var bestAttempt: GameResult {get}
    var averageAccuracy: Double {get}
    var bestAttemptText: String {get}
    
    func storeCurrentResult(correct count: Int, total amount: Int)
    
}
