//
//  ResultViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 14/4/2025.
//

import UIKit
import Lottie
import AVFoundation


class ResultViewController: UIViewController {
    private var animationView: LottieAnimationView!
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var motivationalLabel: UILabel!
    
    
    
    var finalScore = 0
    var gameViewController: UIViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Your Score: \(finalScore)"
        setEmojiForScore()
        setupConfetti()
        showMotivationalComment()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
        setupDynamicBackground()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.stop()
        animateCommentAppearance()
    }
    
    
    
    func setEmojiForScore() {
        let percentage = Double(finalScore) / 20.0 // Max possible score is 20 (4 matches x 5 rounds)
        
        switch percentage {
        case 0.8...1.0:
            emojiLabel.text = "🎉"
            showTrophyAnimation()
            scoreLabel.text = "PERFECT! \(finalScore)/20"
        case 0.6..<0.8:
            emojiLabel.text = "😊"
            showStarAnimation()
            scoreLabel.text = "FANTASTIC! \(finalScore)/20"
        case 0.4..<0.6:
            emojiLabel.text = "🙂"
            scoreLabel.text = "GREAT! \(finalScore)/20"
        default:
            emojiLabel.text = "😕"
            scoreLabel.text = "KEEP TRYING💪! \(finalScore)/20"
        }
        scoreLabel.textColor = UIColor.systemIndigo
        emojiLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 1.0) {
        self.emojiLabel.transform = .identity
            }
    }
    func showMotivationalComment() {
        let percentage = Double(finalScore) / 20.0
        var commentCategory: String
        
        switch percentage {
        case 0.8...1.0:
            commentCategory = "high"
        case 0.5..<0.8:
            commentCategory = "medium"
        default:
            commentCategory = "low"
        }
        
        if let comments = motivationalComments[commentCategory] {
            let randomComment = comments.randomElement() ?? "Good job!"
            motivationalLabel.text = randomComment
            
            // Add animation
            motivationalLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut) {
                self.motivationalLabel.transform = .identity
            }
        }
    }
    func animateCommentAppearance() {
        motivationalLabel.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn) {
            self.motivationalLabel.alpha = 1
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
    func setupDynamicBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemBlue.cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func showTrophyAnimation() {
        let animation = LottieAnimationView(name: "trophy-animation")
        animation.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 300)
        animation.loopMode = .loop
        view.addSubview(animation)
        animation.play()
    }
    func showStarAnimation() {
        let particles = CAEmitterLayer()
        // Configure particle effects
        view.layer.addSublayer(particles)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            particles.removeFromSuperlayer()
        }
    }
    private let motivationalComments: [String: [String]] = [
        "high": [
            "Legendary! 🏆 You nailed it, really did !!",
            "Perfect score! You're a something else aren't you! 🧠",
            "Flawless victory, you are shining 💎",
            "You crushed it, you are unstoppable 🔥",
            "Look who's got max score, too easy for you huh? 🚀"
        ],
        "medium": [
            "Great job! Keep going, i believe in you ✨",
            "You're getting so, so good at it 📈",
            "Nice work! The goal is there in your arm length 😊",
            "Solid performance, love that 👍",
            "You've got skills 💪 show off and keep grinding!"
        ],
        "low": [
            "Good effort! Try again to make yoyrself stronger 💪",
            "Every expert was once a beginner, you got this 🌱",
            "You're learning! That's what matters eh? 📚",
            "Next time you'll do better, keep going! 🔜",
            "The journey begins here, do not give up 🛣️"
        ]
    ]
    
    
    
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
        guard let window = view.window else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "ViewController")

            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.5
            window.layer.add(transition, forKey: kCATransition)
            
            window.rootViewController = homeVC
    }
    
    
}


