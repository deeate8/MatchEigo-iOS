//
//  ViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 21/3/2025.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addFloatingEmojis()
    }
    @IBAction func startEmojiGame () {
        let vc = storyboard?.instantiateViewController(identifier: "emojiGame") as! EmojiGameViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
}
    
    
    @IBAction func startToeicGame(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let toeicVC = storyboard.instantiateViewController(withIdentifier: "ToeicGameController") as? ToeicGameController {
            toeicVC.modalPresentationStyle = .fullScreen
            present(toeicVC, animated: true)
        }
}
    
    func addFloatingEmojis() {
        let emojis = ["✨", "🌟", "🎮", "🏆", "💡", "🎯", "👍", "❤️", "🔥"]
        
        for _ in 0..<15 {
            let emojiLabel = UILabel()
            emojiLabel.text = emojis.randomElement()
            emojiLabel.font = .systemFont(ofSize: 24)
            emojiLabel.textAlignment = .center
            emojiLabel.alpha = 0.8
            
            let startX = CGFloat.random(in: 20..<(view.bounds.width - 20))
            emojiLabel.frame = CGRect(x: startX,
                                      y: view.bounds.height + 50,
                                      width: 30,
                                      height: 30)
            view.addSubview(emojiLabel)
            view.sendSubviewToBack(emojiLabel)
            
            UIView.animate(withDuration: Double.random(in: 8...12),
                           delay: Double.random(in: 0...2),
                           options: [.repeat, .curveLinear]) {
                let endX = startX + CGFloat.random(in: -50...50)
                emojiLabel.frame.origin = CGPoint(
                    x: endX,
                    y: -100
                )
                
                emojiLabel.transform = CGAffineTransform(rotationAngle: .pi)
            }
            
            UIView.animate(withDuration: 2,
                           delay: 0,
                           options: [.autoreverse, .repeat]) {
                emojiLabel.alpha = 0.3
            }
        }
    }
}
