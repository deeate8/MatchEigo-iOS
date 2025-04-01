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
    
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    
    
    let wordPairs = [
        ("🍎", "Apple"),
        ("🍌", "Banana"),
        ("🍊", "Orange"),
        ("🍇", "Grape")
    ]
    
    var selectedQuestionButton: UIButton?
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmojiGame()
    }
    
    func setupEmojiGame() {
        //clear prev selections
        selectedQuestionButton = nil
        score = 0
        
        let shuffledPairs = wordPairs.shuffled()
        let questions = shuffledPairs.map { $0.0 }
        let answers = shuffledPairs.map { $0.1 }
        
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
        // deselect
        selectedQuestionButton?.backgroundColor = .systemBlue
        selectedQuestionButton = sender
        sender.backgroundColor = .systemYellow
    }
    
    
    @IBAction func answerTapped(_ sender: UIButton) {
        guard let questionButton = selectedQuestionButton,
              let questionIndex = questionsStackView.arrangedSubviews.firstIndex(of: questionButton),
              let answerIndex = answersStackView.arrangedSubviews.firstIndex(of: sender) else { return }
        
        let questionWord = wordPairs[questionIndex].0
        let answerWord = wordPairs[answerIndex].1
        
        
        // Checking pairs
        if wordPairs.contains(where: { $0 == (questionWord, answerWord) }) {
            score += 1
            questionButton.isEnabled = false
            sender.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemGreen
                sender.backgroundColor = .systemGreen
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                questionButton.backgroundColor = .systemRed
                sender.backgroundColor = .systemRed
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                questionButton.backgroundColor = .systemBlue
                sender.backgroundColor = .systemBlue
            }
        })
    }
        
        selectedQuestionButton = nil
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
