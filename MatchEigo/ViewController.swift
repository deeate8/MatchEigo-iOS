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
        // Do any additional setup after loading the view.
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
}
