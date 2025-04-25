//
//  EmojiGameViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 26/3/2025.
//

import UIKit
import FirebaseCore
import RealmSwift
import FirebaseFirestore



class EmojiGameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var answersStackView: UIStackView!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    let db = Firestore.firestore()
    
    
    var emojiPairs = [("", "")]
        
       
        
        func fetchEmojiPairs() {
            db.collection("emojiPairs").getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.emojiPairs = documents.compactMap { doc in
                    let emojis = doc["emoji"] as? String ?? ""
                    let english = doc["english"] as? String ?? ""
                    return (emojis, english)
                }
                
                print("Loaded pairs: \(self.emojiPairs)")
                DispatchQueue.main.async { // ← Critical fix
                        self.startNewRound()
                        print("UI should update now")
                    }
            }
        }
    
    
//    var wordPairs = [
//        ("🍎", "Apple"),
//        ("🍌", "Banana"),
//        ("🍊", "Orange"),
//        ("🍇", "Grape"),
//        ("🐶", "Dog"),
//        ("🐱", "Cat"),
//        ("🐭", "Mouse"),
//        ("🐹", "Hamster"),
//        ("🚗", "Car"),
//        ("✈️", "Airplane"),
//        ("🚲", "Bicycle"),
//        ("🚂", "Train")
//    ]
    
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
    
    func setupButtonAppearance() {
        // Apply to question buttons (emojis)
        for button in questionsStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
            button.titleLabel?.lineBreakMode = .byClipping // Prevent line breaks
            // Add to your button configuration
            button.titleLabel?.textAlignment = .center
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            
            
        }
        
        // Apply to answer buttons (words)
        for button in answersStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
        }
        
    }
    
    func configureButton(_ button: UIButton) {
        // 1. Modern iOS 15+ approach
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 20,
                leading: 20,
                bottom: 20,
                trailing: 20
            )
            config.titlePadding = 15
            button.configuration = config
        }
        // 2. Legacy support
        else {
            button.contentEdgeInsets = UIEdgeInsets(
                top: 20,
                left: 20,
                bottom: 20,
                right: 20
            )
        }
        
        // 3. Emoji-specific settings
        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.titleLabel?.lineBreakMode = .byClipping
        
        // 4. Critical: Prevent content clipping
        button.clipsToBounds = false
        button.titleLabel?.clipsToBounds = false
    }
    class EmojiButton: UIButton {
        override var isHighlighted: Bool {
            didSet {
                if isHighlighted != oldValue {
                    if isHighlighted {
                        layer.borderColor = UIColor.systemYellow.cgColor
                        layer.borderWidth = 3
                    } else if !isSelected {
                        layer.borderWidth = 0
                    }
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    layer.borderColor = UIColor.systemYellow.cgColor
                    layer.borderWidth = 3
                } else {
                    layer.borderWidth = 0
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewRound()
        setupButtonAppearance()
        fetchEmojiPairs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // For emoji buttons
        for button in questionsStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.titleLabel?.font = .systemFont(ofSize: min(button.bounds.width, button.bounds.height) * 0.4 )
        }
        
        // For text buttons
        for button in answersStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.titleLabel?.font = .systemFont(ofSize: 15)
        }
    }
    
    
    func setupEmojiGame() {
        score = 0
        currentRound = 1
        matchedPairs = 0
        selectedQuestionButton = nil
        selectedAnswerButton = nil
        startNewRound()
    }
    
    func startNewRound() {
            // Reset for new round
        matchedPairs = 0
        selectedQuestionButton = nil
            
            // Select 4 random pairs
        currentRoundPairs = Array(emojiPairs.shuffled().prefix(4))
            
            // Separate and shuffle questions and answers
        let questions = currentRoundPairs.map { $0.0 }.shuffled()
        let answers = currentRoundPairs.map { $0.1 }.shuffled()
        
//        for (index, button) in questionsStackView.arrangedSubviews.enumerated() {
//            (button as? UIButton)?.setTitle(questions[index], for: .normal)
//            button.backgroundColor = .systemBlue
//            (button as? UIButton)?.isEnabled = true
//        }
//        
//        for (index, button) in answersStackView.arrangedSubviews.enumerated() {
//            (button as? UIButton)?.setTitle(answers[index], for: .normal)
//            button.backgroundColor = .systemBlue
//            (button as? UIButton)?.isEnabled = true
//        }
        for (index, button) in questionsStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton,
                  index < questions.count else { continue }
            button.setTitle(questions[index], for: .normal)
            button.isEnabled = true
            button.backgroundColor = .systemBlue
        }

        // For answer buttons (Japanese words)
        for (index, button) in answersStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton,
                  index < answers.count else { continue }
            button.setTitle(answers[index], for: .normal)
            button.isEnabled = true
            button.backgroundColor = .systemBlue
        }
    }
    
    @IBAction func questionTapped(_ sender: UIButton) {
        
        if sender == selectedQuestionButton {
            selectedQuestionButton?.layer.borderWidth = 0
            selectedQuestionButton = nil
            return
        }
        selectedQuestionButton?.layer.borderWidth = 0
        
        selectedQuestionButton = sender
        sender.layer.borderColor = UIColor.systemYellow.cgColor
        sender.layer.borderWidth = 6
        checkForMatch()
    }
    
//TODO: highlight the color
    
    
    @IBAction func answerTapped(_ sender: UIButton) {
        if sender == selectedAnswerButton {
            selectedAnswerButton?.backgroundColor = .systemBlue
            selectedAnswerButton = nil
            return
        }
        selectedAnswerButton?.backgroundColor = .systemBlue
        selectedAnswerButton = sender
        sender.backgroundColor = .systemYellow
        
        checkForMatch()
    }
        
    func checkForMatch() {
        guard let questionButton = selectedQuestionButton,
              let answerButton = selectedAnswerButton,
              let questionIndex = questionsStackView.arrangedSubviews.firstIndex(of: questionButton),
              let answerIndex = answersStackView.arrangedSubviews.firstIndex(of: answerButton) else { return }
        
        let selectedEmoji = (questionButton.titleLabel?.text)!
        let selectedAnswer = (answerButton.titleLabel?.text)!
        
        
        // Checking pairs
        if currentRoundPairs.contains(where: { $0 == (selectedEmoji, selectedAnswer) }) {
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
            
            if matchedPairs == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkGameProgress()
                }
            }
        } else {
            score = max(0, score - 1)
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemRed
                answerButton.backgroundColor = .systemRed
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    questionButton.backgroundColor = .systemBlue
                    answerButton.backgroundColor = .systemBlue
                }
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Leave Game?", message: "Your progress will be saved :)", preferredStyle: .alert)
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
        
        // Start fresh 5 rounds
        setupEmojiGame()
        
        // Optional: Shuffle all word pairs for new session
        emojiPairs.shuffle()
    }
    
    
    // TODO: saving data in Realm
}
