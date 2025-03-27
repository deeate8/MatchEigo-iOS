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
    
    func setupEmojiGame() { //clear prev selections
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

    }
    
    
}
