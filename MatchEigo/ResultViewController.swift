//
//  ResultViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 14/4/2025.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    var finalScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Your Score: \(finalScore)"
        setEmojiForScore()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setEmojiForScore() {
        let percentage = Double(finalScore) / 20.0 // Max possible score is 20 (4 matches x 5 rounds)
        
        switch percentage {
        case 0.8...1.0:
            emojiLabel.text = "🎉"
        case 0.6..<0.8:
            emojiLabel.text = "😊"
        case 0.4..<0.6:
            emojiLabel.text = "🙂"
        default:
            emojiLabel.text = "😕"
        }
    }
    
    @IBAction func playAgainTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func exitTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}

