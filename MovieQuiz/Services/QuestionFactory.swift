import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    //    let questions: [QuizQuestion] = [
    //        QuizQuestion(imageName: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(imageName: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(imageName: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(imageName: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    //    ]
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomThreshold = Float.random(in: 6.0...9.0)
        
            let text = String(format: "Рейтинг этого фильма больше чем %.1f?", randomThreshold)
            let correctAnswer = rating > randomThreshold
            
            let question = QuizQuestion(imageName: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
