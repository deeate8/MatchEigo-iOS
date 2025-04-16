//
//  EmojiGameViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 26/3/2025.
//

import UIKit
import RealmSwift

class EmojiGameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var answersStackView: UIStackView!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    
    
    let wordPairs = [
        ("🍎", "Apple"),
        ("🍌", "Banana"),
        ("🍊", "Orange"),
        ("🍇", "Grape"),
        ("🐶", "Dog"),
        ("🐱", "Cat"),
        ("🐭", "Mouse"),
        ("🐹", "Hamster"),
        ("🚗", "Car"),
        ("✈️", "Airplane"),
        ("🚲", "Bicycle"),
        ("🚂", "Train")
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
    
    func setupButtonAppearance() {
        // Apply to question buttons (emojis)
        for button in questionsStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
        }
        
        // Apply to answer buttons (words)
        for button in answersStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewRound()
        setupButtonAppearance()
    }
    
    func startNewRound() {
            // Reset for new round
        matchedPairs = 0
        selectedQuestionButton = nil
            
            // Select 4 random pairs
        currentRoundPairs = Array(wordPairs.shuffled().prefix(4))
            
            // Separate and shuffle questions and answers
        let questions = currentRoundPairs.map { $0.0 }.shuffled()
        let answers = currentRoundPairs.map { $0.1 }.shuffled()
        
        for (index, button) in questionsStackView.arrangedSubviews.enumerated() {
            (button as? UIButton)?.setTitle(questions[index], for: .normal)
            button.backgroundColor = .systemBlue
            (button as? UIButton)?.isEnabled = true
        }
        
        for (index, button) in answersStackView.arrangedSubviews.enumerated() {
            (button as? UIButton)?.setTitle(answers[index], for: .normal)
            button.backgroundColor = .systemBlue
            (button as? UIButton)?.isEnabled = true
        }
    }
    
    @IBAction func questionTapped(_ sender: UIButton) {
        if sender == selectedQuestionButton {
                    selectedQuestionButton?.backgroundColor = .systemBlue
                    selectedQuestionButton = nil
                    return
                }
        
        // deselect
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
    // TODO: saving data in Realm
            }
