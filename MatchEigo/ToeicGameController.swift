//
//  ToeicGameController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 16/4/2025.
//

import UIKit
import FirebaseCore
import RealmSwift
import FirebaseFirestore

class ToeicGameController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    @IBOutlet weak var questionsStackView: UIStackView!
    
    
    @IBOutlet weak var answerStackView: UIStackView!
    
    // MARK: - Properties
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    let db = Firestore.firestore()
    var wordPairs = [("", "")]
    var selectedQuestionButton: UIButton?
    var selectedAnswerButton: UIButton?
    let timerService = TimerService.shared
    var elapsedTime: Double = 0
    var timer: Timer?
    
    @IBOutlet weak var timerLabel: UILabel!
    
    func fetchWordPairs() {
            db.collection("wordPairs").getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.wordPairs = documents.compactMap { doc in
                    guard let english = doc["english"] as? String,
                          let japanese = doc["japanese"] as? String else {
                        print("Invalid document format")
                        return nil
                    }
                    return (english, japanese)
                }
                
                DispatchQueue.main.async {
                    self.startNewRound()
                }
            }
        }
    

    
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    var currentRound = 1 {
        didSet { roundLabel.text = "Round: \(currentRound)/5" }
    }
    var matchedPairs = 0
    var currentRoundPairs: [(String, String)] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonAppearance()
        startNewRound()
        fetchWordPairs()
    }
    
    // MARK: - Game Setup
    func setupButtonAppearance() {
        let allButtons = questionsStackView.arrangedSubviews + answerStackView.arrangedSubviews
        for button in allButtons.compactMap({ $0 as? UIButton }) {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.titleLabel?.numberOfLines = 1
        }
    }
    
    func resetGame() {
        score = 0
        currentRound = 1
        matchedPairs = 0
        selectedQuestionButton = nil
        selectedAnswerButton = nil
        startNewRound()
    }
    
    func startNewRound() {
        matchedPairs = 0
        selectedQuestionButton = nil
        selectedAnswerButton = nil
        if currentRound == 1 {
            timerService.startRound()
            startLiveTimer()
        }
        guard wordPairs.count >= 4 else {
                print("Not available")
                return
            }

        currentRoundPairs = Array(wordPairs.shuffled().prefix(4))
        
        // Separate and shuffle questions (English) and answers (Japanese)
        let englishWords = currentRoundPairs.map { $0.0 }.shuffled()
        let japaneseWords = currentRoundPairs.map { $0.1 }.shuffled()
        
        for (index, view) in questionsStackView.arrangedSubviews.enumerated() {
                guard let button = view as? UIButton, index < englishWords.count else { continue }
                button.setTitle(englishWords[index], for: .normal)
                button.backgroundColor = .systemBlue
                button.isEnabled = true
        }
        
        // Update answer buttons (Japanese)
        for (index, button) in answerStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton,
                  index < japaneseWords.count else { continue }
            
            button.setTitle(japaneseWords[index], for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.isEnabled = true
        }
    }
    
    // MARK: - Button Actions
    @IBAction func questionTapped(_ sender: UIButton) {
        // Deselect if same button tapped again
        if sender == selectedQuestionButton {
            selectedQuestionButton?.backgroundColor = .systemBlue
            selectedQuestionButton = nil
            return
        }
        
        // Deselect previous selection
        selectedQuestionButton?.backgroundColor = .systemBlue
        selectedQuestionButton = sender
        sender.backgroundColor = .systemYellow
        checkForMatch()
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        if sender == selectedAnswerButton {
            selectedAnswerButton?.backgroundColor = .systemBlue
            selectedAnswerButton = nil
            return
        }
        
        selectedAnswerButton?.backgroundColor = .systemBlue
        selectedAnswerButton = sender
        sender.backgroundColor = .systemOrange
        checkForMatch()
    }
    
    func checkForMatch() {
        guard let questionButton = selectedQuestionButton,
              let answerButton = selectedAnswerButton,
              let questionIndex = questionsStackView.arrangedSubviews.firstIndex(of: questionButton),
              let answerIndex = answerStackView.arrangedSubviews.firstIndex(of: answerButton) else { return }
        
        let selectedEnglish = (questionButton.titleLabel?.text)!
        let selectedJapanese = (answerButton.titleLabel?.text)!
        
        // Check if this is a correct pair
        if currentRoundPairs.contains(where: { $0 == (selectedEnglish, selectedJapanese) }) {
            score += 1
            matchedPairs += 1
            questionButton.isEnabled = false
            answerButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemGreen
                answerButton.backgroundColor = .systemGreen
            })
            
            selectedQuestionButton = nil
            selectedAnswerButton = nil
            
            // Check if round is complete
            if matchedPairs == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkGameProgress()
                }
            }
        } else {
            // Incorrect match - deduct points
            score = max(0, score - 1)
            
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemRed
                answerButton.backgroundColor = .systemRed
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    questionButton.backgroundColor = .systemBlue
                    answerButton.backgroundColor = .systemBlue
                }
                // Clear selections after showing wrong match
                self.selectedQuestionButton = nil
                self.selectedAnswerButton = nil
            })
        }
    }
    
    func checkGameProgress() {
            if currentRound < 5 {
                currentRound += 1
                startNewRound()
            } else {
                // Game over, show results
                let totalTime = timerService.endRound()
                timer?.invalidate()
                showResult(with: totalTime)
            }
        }
    
    func showResult(with totalTime: Double) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultsVC.finalScore = score
            resultsVC.totalTime = totalTime
            resultsVC.gameViewController = self
            resultsVC.modalPresentationStyle = .fullScreen
            present(resultsVC, animated: true)
        }
    }
    
    // MARK: - Navigation
    @IBAction func backTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Leave Game?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .default) { _ in
            let transition = CATransition()
            
            //            3D Block animation
            transition.type = CATransitionType(rawValue: "cube")
            transition.subtype = .fromLeft
            transition.duration = 0.8
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.view.window?.layer.add(transition, forKey: nil)
            self.tabBarController?.selectedIndex = 0
            
            if let window = self.view.window {
                window.layer.add(transition, forKey: kCATransition)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                window.rootViewController = tabBarController
            }
        })
        present(alert, animated: true)
    }
    
    func resetGameForNewSession() {
        // Reset all game state
        score = 0
        currentRound = 1
        matchedPairs = 0
        selectedQuestionButton = nil
        selectedAnswerButton = nil
        timer?.invalidate()
        startNewRound()
        wordPairs.shuffle()
    }
    
    func startLiveTimer() {
        timer?.invalidate()
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.1
            self.updateTimerLabel()
        }
    }
    func updateTimerLabel() {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            timerLabel.text = formatter.string(from: elapsedTime)
 }
}
