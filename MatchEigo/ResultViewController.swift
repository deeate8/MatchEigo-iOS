//
//  ResultViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 14/4/2025.
//

import UIKit
import Lottie

class ResultViewController: UIViewController {
    private var animationView: LottieAnimationView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    var finalScore = 0
    var gameViewController: UIViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Your Score: \(finalScore)"
        setEmojiForScore()
        setupConfetti()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.stop()
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
    
    func setupConfetti() {
        animationView = LottieAnimationView(name: "Animation - 1744771209260")
        
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFill
        
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.5
        
        view.addSubview(animationView)
        view.sendSubviewToBack(animationView)
        animationView.frame = CGRect(
            x: 0,
            y: view.frame.height / 3,
            width: view.frame.width,
            height: 300
        )
    }
    
    
    
    
    
    @IBAction func playAgainTapped(_ sender: UIButton) {
        
        dismiss(animated: true) { [weak self] in
            if let emojiVC = self?.gameViewController as? EmojiGameViewController {
                emojiVC.resetGameForNewSession()
            }
            else if let toeicVC = self?.gameViewController as? ToeicGameController {
                toeicVC.resetGameForNewSession()
            }
        }
    }
    
    @IBAction func exitTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}


