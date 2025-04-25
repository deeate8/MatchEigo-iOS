//
//  ToeicGameController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 16/4/2025.
//

import UIKit
import RealmSwift

class ToeicGameController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    @IBOutlet weak var questionsStackView: UIStackView!
    
    
    @IBOutlet weak var answerStackView: UIStackView!
    
    
    // MARK: - Properties
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    // English-Japanese word pairs (TOEIC 0-300 level)
    var wordPairs = [
        ("Hello", "こんにちは"),
        ("Goodbye", "さようなら"),
        ("Thank you", "ありがとう"),
        ("Yes", "はい"),
        ("No", "いいえ"),
        ("Book", "本"),
        ("Pen", "ペン"),
        ("School", "学校"),
        ("Water", "水"),
        ("Food", "食べ物"),
        ("Money", "お金"),
        ("Time", "時間"),
        ("Day", "日"),
        ("Night", "夜"),
        ("Friend", "友達"),
        ("Family", "家族"),
        ("House", "家"),
        ("Car", "車"),
        ("Train", "電車"),
        ("Phone", "電話")
    ]
    
    var selectedQuestionButton: UIButton?
    var selectedAnswerButton: UIButton?
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
        
        // Select 4 random pairs
        currentRoundPairs = Array(wordPairs.shuffled().prefix(4))
        
        // Separate and shuffle questions (English) and answers (Japanese)
        let englishWords = currentRoundPairs.map { $0.0 }.shuffled()
        let japaneseWords = currentRoundPairs.map { $0.1 }.shuffled()
        
        // Update question buttons (English)
        for (index, button) in questionsStackView.arrangedSubviews.enumerated() {
            (button as? UIButton)?.setTitle(englishWords[index], for: .normal)
            button.backgroundColor = .systemBlue
            (button as? UIButton)?.isEnabled = true
        }
        
        // Update answer buttons (Japanese)
        for (index, button) in answerStackView.arrangedSubviews.enumerated() {
            (button as? UIButton)?.setTitle(japaneseWords[index], for: .normal)
            button.backgroundColor = .systemBlue
            (button as? UIButton)?.isEnabled = true
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
        
        // Check for match if both selections are made
        checkForMatch()
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        // Deselect if same button tapped again
        if sender == selectedAnswerButton {
            selectedAnswerButton?.backgroundColor = .systemBlue
            selectedAnswerButton = nil
            return
        }
        
        // Deselect previous selection
        selectedAnswerButton?.backgroundColor = .systemBlue
        selectedAnswerButton = sender
        sender.backgroundColor = .systemOrange
        
        // Check for match if both selections are made
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
            // Correct match
            score += 1
            matchedPairs += 1
            questionButton.isEnabled = false
            answerButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemGreen
                answerButton.backgroundColor = .systemGreen
            })
            
            // Clear selections
            selectedQuestionButton = nil
            selectedAnswerButton = nil
            
            // Check if round is complete
            if matchedPairs == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkGameProgress()
                }
            }
        } else {
            // Incorrect match - deduct points (minimum 0)
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
            showResults()
        }
    }
    
    func showResults() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultsVC.finalScore = score
            resultsVC.gameViewController = self
            resultsVC.modalPresentationStyle = .fullScreen
            present(resultsVC, animated: true)
        }
    }
    
    // MARK: - Navigation
    @IBAction func backTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Leave Game?", message: "Your progress will be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .default) { _ in
            self.dismiss(animated: true)
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
        
        // Start fresh 5 rounds
        startNewRound()
        
        // Optional: Shuffle all word pairs for new session
        wordPairs.shuffle()
    }
}
